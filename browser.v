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
	firefox
	edge
}

pub type Strings = string | []string

@[heap]
pub struct Browser {
pub:
	typ     BrowserType
	args    []string
	port    int
	ch      chan string
	timeout i64
	ws_url  string
pub mut:
	browser_context_id ?string
	target_id          string
	next_id            int               = 1
	ws                 &websocket.Client = unsafe { nil }
	base_url           string
	pages              []Page
mut:
	process   &os.Process = unsafe { nil }
	has_init  bool        = true
	emits     []EmitData
	use_pages bool
}

@[params]
pub struct Config {
pub:
	base_url        string
	ws_url          string
	args            []string
	executable_path ?string
	port            int = 9222
	user_data_dir   ?string
	headless        bool   = true
	host            string = 'localhost'
	secure          bool
	timeout         i64         = 60 * time.second
	typ             BrowserType = .chrome
	incognito       bool
	use_pages       bool
	maximized       bool
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
	mut ws_url := opts.ws_url
	if ws_url == '' {
		tt := 1 * time.second
		for {
			time.sleep(tt)
			v_res = get_version_hell(url + '/version')
			if v_res.status_code == 200 {
				break
			}
		}
		ws_url = json.decode[json.Any](v_res.body)!.as_map()['webSocketDebuggerUrl']!.str()
		if ws_url == '' {
			return error('cannot find socket url.')
		}
	}
	ch := chan string{}
	mut ws := websocket.new_client(ws_url, logger: error_logger)!
	mut bwr := &Browser{
		ws_url:    ws_url
		ch:        ch
		ws:        ws
		args:      opts.args
		port:      opts.port
		timeout:   opts.timeout
		base_url:  base_url
		use_pages: opts.use_pages
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
	ws.on_error_ref(fn (mut ws websocket.Client, err string, mut bwr Browser) ! {
		eprintln('ws.on_error error: ${err}')
		bwr.close(force: true)
	}, bwr)
	ws.connect()!
	spawn ws.listen()
	wait_for_idle(on_open.ch)!
	result := bwr.send('Target.getTargets')!.result
	targets := result['targetInfos']!.arr()
	mut target_id := ''
	for target in targets {
		target_map := target.as_map()
		if target_map['type'] or { '' }.str() == 'page' {
			target_id = target_map['targetId'] or { '' }.str()
			break
		}
	}
	if target_id == '' {
		return error('no target_id detected!')
	}
	bwr.target_id = target_id
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
	return create_connection(opts)!
}

fn get_typ_browser(typ BrowserType) !string {
	return match typ {
		.chrome { find_chrome()! }
		.edge { find_edge()! }
		.firefox { find_firefox()! }
	}
}

pub fn open_browser(opts Config) !&Browser {
	executable_path := opts.executable_path or { get_typ_browser(opts.typ)! }

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
	if opts.maximized {
		args << '--start-maximized'
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
			bwr = create_connection(cfg) or {
				cmd.signal_kill()
				panic(err)
			}
			has_ready = true
			break
		}
	}
	bwr.process = cmd
	return bwr
}

pub fn open_chrome(opts Config) !&Browser {
	return open_browser(Config{ ...opts, typ: .chrome })
}

pub fn open_edge(opts Config) !&Browser {
	return open_browser(Config{ ...opts, typ: .edge })
}

pub fn open_firefox(opts Config) !&Browser {
	return open_browser(Config{ ...opts, typ: .firefox })
}

pub fn open_safari(opts Config) !&Browser {
	return error('not supported')
}

pub fn open_opera(opts Config) !&Browser {
	return error('not supported')
}

@[noreturn]
fn (mut bwr Browser) noop(err IError) {
	bwr.close(force: true)
	panic(err)
}

fn (mut bwr Browser) get_next_id(current_id int) int {
	mut id := current_id
	if id == -1 {
		id = bwr.next_id++
	}
	return id
}

pub fn (mut bwr Browser) send(method string, params MessageParams) !Result {
	id := bwr.get_next_id(params.id)
	msg := MessageParams{
		...params
		method: method
		id:     id
	}
	data := json.encode(msg)
	bwr.ws.write_string(data)!
	return bwr.recv_method(msg)!
}

fn (mut bwr Browser) send_or_noop(method string, params MessageParams) Result {
	return bwr.send(method, params) or { bwr.noop(err) }
}

fn (mut bwr Browser) send_event_or_noop(method string, params MessageParams) Result {
	return bwr.send_event(method, params) or { bwr.noop(err) }
}

pub fn (mut bwr Browser) send_event(method string, params MessageParams) !Result {
	return bwr.send(method, MessageParams{ ...params, typ: .event })!
}

fn (mut bwr Browser) recv_method(params MessageParams) !Result {
	mut data, id, method := map[string]json.Any{}, params.id, params.method
	session_id, typ := params.session_id or { '' }, params.typ
	mut t_error := map[string]json.Any{}
	mut is_error := false
	for {
		select {
			raw := <-bwr.ch {
				data = json.decode[json.Any](raw)!.as_map()
				if session_id == data['sessionId'] or { '' }.str() {
					if d_error := data['error'] {
						t_error = d_error.as_map()
						is_error = true
					}
					d_method := data['method'] or { json.Any('') }.str()
					if d_method != '' {
						if d_params := data['params'] {
							d_msg := Message{
								method:     d_method
								params:     d_params.as_map()
								session_id: session_id
							}
							if !isnil(params.cb) {
								params.cb(d_msg, params.ref)!
							}
							bwr.emit(d_method, d_msg)
						}
					}
					if typ == .command {
						if data['id'] or { json.Any(-2) }.int() == id {
							break
						}
					} else if typ == .event {
						if d_method == method {
							break
						}
					}
				}
			}
			bwr.timeout {
				return error('connection failed')
			}
		}
	}
	return Result{
		method:     method
		id:         id
		session_id: session_id
		result:     data['result'] or { json.Any{} }.as_map()
		error:      t_error
		is_error:   is_error
	}
}

@[params]
pub struct BrowserCloseParams {
pub:
	force bool
}

pub fn (mut bwr Browser) close(opts BrowserCloseParams) {
	if ctx_id := bwr.browser_context_id {
		bwr.send_or_noop('Target.disposeBrowserContext',
			params: {
				'browserContextId': ctx_id
			}
		)
		if !opts.force {
			return
		}
	}
	bwr.process.signal_kill()
	if !isnil(bwr.ws) {
		bwr.ws.close(1000, 'normal') or { eprintln('browser is closed') }
	}
	if !bwr.ch.closed {
		bwr.ch.close()
	}
}

fn (mut bwr Browser) add_page(mut page Page) {
	bwr.pages << page
}

fn (mut bwr Browser) struct_to_json_any[T](d T) json.Any {
	return struct_to_json_any[T](d) or { bwr.noop(err) }
}

pub struct BrowserVersion {
pub:
	protocol_version string @[json: 'protocolVersion']
	product          string @[json: 'product']
	revision         string @[json: 'revision']
	user_agent       string @[json: 'userAgent']
	v8_version       string @[json: 'jsVersion']
}

pub fn (mut bwr Browser) get_version() BrowserVersion {
	res := bwr.send_or_noop('Browser.getVersion').result
	return json.decode[BrowserVersion](res.str()) or { bwr.noop(err) }
}
