module cdv

import net.websocket
import net.http
import x.json2 as json
import time
import os
import log

const base_cache = os.cache_dir() + '/cdv'

pub enum BrowserType {
	chrome
}

@[heap]
pub struct Browser {
pub:
	typ          BrowserType
	args         []string
	port         int
	ch           chan string
	target_id    string
	timeout_recv i64
pub mut:
	next_id  int               = 1
	ws       &websocket.Client = unsafe { nil }
	base_url string
mut:
	tabs    [][]string
	process &os.Process = unsafe { nil }
}

@[params]
pub struct Config {
pub:
	args            []string
	executable_path ?string
	port            int = 9222
	user_data_dir   ?string
	headless        bool   = true
	host            string = 'localhost'
	secure          bool
	timeout         i64 = 1 * time.second
	timeout_recv    i64 = 60 * time.second
	open_browser    bool
	base_url        string
	typ             BrowserType = .chrome
	incognito       bool
}

struct OnOpen {
	ch chan int
}

const error_logger = setup_error_logger()

fn setup_error_logger() &log.Log {
	mut l := &log.Log{}
	l.set_level(.error)
	return l
}

fn create_connection(opts Config) !&Browser {
	base_url := get_base_url(opts)
	url := base_url + '/json'
	mut v_res := http.Response{}
	for {
		time.sleep(opts.timeout)
		v_res = get_version_hell(url + '/version')
		if v_res.status_code == 200 {
			break
		}
	}
	ws_url := json.decode[json.Any](v_res.body)!.as_map()['webSocketDebuggerUrl']!.str()
	if ws_url == '' {
		return error('cannot find socket url.')
	}
	res_target := fetch_data(url, .get)!
	targets := json.decode[json.Any](res_target.body)!.arr()
	mut target_id := ''
	for target in targets {
		target_map := target.as_map()
		if target_map['type']!.str() == 'page' {
			target_id = target_map['id']!.str()
			break
		}
	}
	if target_id == '' {
		return error('no target_id detected!')
	}
	ch := chan string{}
	mut ws := websocket.new_client(ws_url, logger: error_logger)!
	mut bwr := &Browser{
		target_id:    target_id
		ch:           ch
		ws:           ws
		args:         opts.args
		port:         opts.port
		timeout_recv: opts.timeout_recv
		base_url:     base_url
	}
	on_open := &OnOpen{
		ch: chan int{cap: 1}
	}
	ws.on_open_ref(fn (mut ws websocket.Client, data &OnOpen) ! {
		data.ch <- 1
	}, on_open)
	ws.on_message_ref(fn (mut ws websocket.Client, msg &websocket.Message, mut bwr Browser) ! {
		if msg.payload.len > 0 {
			bwr.ch <- msg.payload.bytestr()
		}
	}, bwr)
	ws.on_error(fn (mut ws websocket.Client, err string) ! {
		eprintln('ws.on_error error: ${err}')
	})
	ws.connect()!
	spawn ws.listen()
	wait_for_idle(on_open.ch)!
	return bwr
}

fn wait_for_idle(ch chan int) ! {
	for {
		select {
			_ := <-ch {
				if !ch.closed {
					ch.close()
				}
				break
			}
			10 * time.second {
				return error('cannot open browser')
			}
		}
	}
}

pub fn connect(opts Config) !&Browser {
	if opts.open_browser {
		return open_browser(opts)!
	}
	return create_connection(opts)!
}

pub fn open_browser(opts Config) !&Browser {
	executable_path := opts.executable_path or {
		if opts.typ == .chrome { find_chrome()! } else { '' }
	}

	mut args := []string{}
	if executable_path == '' {
		return error('cannot find executable_path')
	}
	user_dir := opts.user_data_dir or {
		mut dir := base_cache + '/' + opts.typ.str()
		if opts.headless {
			dir += '/headless'
		} else {
			dir += '/browser'
		}
		if !os.exists(dir) {
			os.mkdir_all(dir)!
		}
		dir
	}

	args << def_args
	args << opts.args
	args << '--remote-debugging-port=${opts.port}'
	args << '--user-data-dir=${user_dir}'
	if opts.headless {
		args << '--headless'
		args << '--disable-gpu'
	}
	if opts.incognito {
		args << '--incognito'
	}
	mut cmd := os.new_process(executable_path)
	cmd.set_args(args)
	cmd.set_redirect_stdio()
	cmd.run()
	mut has_ready := false
	mut bwr := &Browser{}
	cfg := Config{
		...opts
		args:            args
		user_data_dir:   user_dir
		executable_path: executable_path
	}
	for cmd.is_alive() {
		if !has_ready {
			bwr = create_connection(cfg)!
			has_ready = true
			break
		}
	}
	bwr.process = cmd
	return bwr
}

pub fn open_chrome(opts Config) !&Browser {
	return open_browser(opts)
}

pub fn open_firefox(opts Config) !&Browser {
	return error('not supported')
}

@[params]
pub struct ApiOptions {
pub:
	target_id string
}

pub fn (mut bwr Browser) get_version() !http.Response {
	return fetch_data('${bwr.base_url}/json/version', .get)!
}

pub fn (mut bwr Browser) get_targets() !http.Response {
	return fetch_data('${bwr.base_url}/json/list', .get)!
}

pub fn (mut bwr Browser) get_protocol() !http.Response {
	return fetch_data('${bwr.base_url}/json/protocol', .get)!
}

pub fn (mut bwr Browser) get_active_tab(opts ApiOptions) !http.Response {
	target_id := if opts.target_id == '' { bwr.target_id } else { opts.target_id }
	return fetch_data('${bwr.base_url}/json/activate/${target_id}', .get)!
}

pub fn (mut bwr Browser) get_close_tab(opts ApiOptions) !http.Response {
	target_id := if opts.target_id == '' { bwr.target_id } else { opts.target_id }
	return fetch_data('${bwr.base_url}/json/close/${target_id}', .get)!
}

pub fn (mut bwr Browser) put_new_tab(url string) !http.Response {
	return fetch_data('${bwr.base_url}/json/new?${url}', .put)!
}

pub enum MessageType {
	command
	event
}

pub type EventFunc = fn (res Result, ref voidptr) !

@[params]
pub struct Message {
pub:
	id         int = -1
	method     string
	params     ?map[string]json.Any
	session_id ?string   @[json: 'sessionId']
	cb         EventFunc = unsafe { nil } @[json: '-']
	wait       bool      = true      @[json: '-']
	ref        voidptr   = unsafe { nil }   @[json: '-']
}

fn (mut bwr Browser) get_next_id(current_id int) int {
	mut id := current_id
	if id == -1 {
		id = bwr.next_id++
	}
	return id
}

fn (mut bwr Browser) send_method(method string, typ MessageType, message Message) !Result {
	id := bwr.get_next_id(message.id)
	msg := Message{
		...message
		method: method
		id:     id
	}
	data := json.encode(msg)
	bwr.ws.write_string(data)!
	if !msg.wait {
		th := spawn bwr.recv_method(typ, msg)
		return Result{
			method: method
			state:  .pending
			th:     th
			id:     id
		}
	}
	return bwr.recv_method(typ, msg)!
}

pub fn (mut bwr Browser) send(method string, msg Message) !Result {
	if method !in map_method {
		return error('unknown method')
	}
	return bwr.send_method(method, map_method[method], msg)
}

pub fn (mut bwr Browser) on(method string, msg Message) !Result {
	if method !in map_method {
		return error('unknown method')
	}
	return bwr.send_method(method, .event, msg)
}

pub fn (mut bwr Browser) recv_method(typ MessageType, msg Message) !Result {
	mut data, id, method := map[string]json.Any{}, msg.id, msg.method
	mut is_ok := false
	for {
		select {
			raw := <-bwr.ch {
				data = json.decode[json.Any](raw)!.as_map()
				if !isnil(msg.cb) {
					res := Result{
						method: method
						id:     id
						data:   data
					}
					msg.cb(res, msg.ref)!
				}
				if typ == .command {
					if data['id'] or { json.Any(-2) }.int() == id {
						is_ok = true
						break
					}
				} else if typ == .event {
					if data['method'] or { json.Any('') }.str() == method {
						is_ok = true
						break
					}
				}
			}
			bwr.timeout_recv {
				return error('connection failed')
			}
		}
	}
	if !is_ok {
		data = map[string]json.Any{}
	}
	return Result{
		method: method
		id:     id
		data:   data
	}
}

pub fn (mut bwr Browser) close() {
	if !isnil(bwr.ws) {
		bwr.send('Browser.close') or {
			if !isnil(bwr.process) {
				bwr.process.signal_kill()
				return
			}
			eprintln('browser is close')
		}
		if bwr.ws.get_state() != .closed {
			bwr.ws.close(1000, 'normal') or { eprintln('browser is closed') }
		}
	} else if !isnil(bwr.process) {
		bwr.process.signal_kill()
	}
	if !bwr.ch.closed {
		bwr.ch.close()
	}
}

pub fn (mut bwr Browser) get_tab(target_id string) !&Tab {
	for mut arr in bwr.tabs {
		if arr[0] == target_id {
			res := bwr.get_active_tab(target_id: target_id)!
			if res.status_code != 200 {
				return error('error when activate target "${target_id}"')
			}
			return &Tab{
				target_id:  target_id
				session_id: arr[1]
				browser:    bwr
			}
		}
	}
	return error('cannot find tab for target_id "${target_id}"')
}
