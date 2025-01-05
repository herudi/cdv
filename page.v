module cdv

import x.json2 as json
import net.urllib

@[heap]
pub struct Page {
pub mut:
	next_id    int = 1
	target_id  string
	browser    &Browser = unsafe { nil }
	session_id string
	deps       []string
	var_id     int = 1
}

pub fn (mut page Page) str() string {
	return 'Page{
	next_id: ${page.next_id}
	target_id: ${page.target_id}
	browser: &Browser{...}
	session_id: ${page.session_id}
	deps: ${page.deps}
	var_id: ${page.var_id}
}'
}

pub struct Viewport {
pub:
	x      ?f64
	y      ?f64
	width  ?f64
	height ?f64
	scale  ?f64
}

pub fn (mut bwr Browser) new_page_opt(data MessageParams) !&Page {
	mut target_id := ''
	if bwr.has_init && data.params == none && bwr.browser_context_id == none {
		target_id = bwr.target_id
		bwr.has_init = false
	} else {
		mut params := data.params or {
			map[string]json.Any{}
		}
			.clone()
		params['url'] = 'about:blank'
		if ctx_id := bwr.browser_context_id {
			params['browserContextId'] = ctx_id
		}
		new_target := bwr.send('Target.createTarget', params: params)!.result
		target_id = new_target['targetId']!.str()
	}
	attach := bwr.send('Target.attachToTarget',
		params: {
			'targetId': json.Any(target_id)
			'flatten':  true
		}
	)!.result
	session_id := attach['sessionId']!.str()
	mut page := &Page{
		target_id:  target_id
		browser:    bwr
		session_id: session_id
	}
	page.enable(['Page', 'DOM', 'Network', 'Runtime'])
	if bwr.use_pages {
		bwr.add_page(mut page)
	}
	return page
}

pub fn (mut bwr Browser) new_page(data MessageParams) &Page {
	return bwr.new_page_opt(data) or { bwr.noop(err) }
}

pub fn (mut page Page) send(method string, params MessageParams) !Result {
	id := page.get_next_id(params.id)
	return page.browser.send(method, MessageParams{ ...params, id: id, session_id: page.session_id })!
}

fn (mut page Page) send_or_noop(method string, params MessageParams) Result {
	return page.send(method, params) or { page.noop(err) }
}

fn (mut page Page) send_warn(method string, params MessageParams) Result {
	res := page.send_or_noop(method, params)
	if res.is_error {
		msg := json.Any(res.error).prettify_json_str()
		eprintln(msg)
	}
	return res
}

fn (mut page Page) struct_to_json_any[T](d T) json.Any {
	return page.browser.struct_to_json_any(d)
}

pub fn (mut page Page) send_event(method string, msg MessageParams) !Result {
	return page.send(method, MessageParams{ ...msg, typ: .event })!
}

fn (mut page Page) send_event_or_noop(method string, msg MessageParams) Result {
	return page.send_event(method, msg) or { page.noop(err) }
}

@[params]
pub struct CloseTargetConfig {
pub:
	force_close_browser bool
}

pub fn (mut page Page) close(opts CloseTargetConfig) {
	if opts.force_close_browser || page.target_id != page.browser.target_id {
		page.close_target()
		return
	}
	page.send('Page.navigate',
		params: {
			'url': 'about:blank'
		}
	) or {}
}

fn (mut page Page) close_target() {
	page.send('Target.closeTarget',
		params: {
			'targetId': page.target_id
		}
	) or {
		eprintln('tab is closed')
		return
	}
}

fn (mut page Page) get_next_id(current_id int) int {
	mut id := current_id
	if id == -1 {
		id = page.next_id++
	}
	return id
}

pub fn (mut page Page) enable(domain Strings, msg MessageParams) {
	if domain.type_name() == 'string' {
		domain_str := domain as string
		if !page.deps.contains(domain_str) {
			page.send_or_noop('${domain_str}.enable', msg)
			page.deps << domain_str
		}
		return
	}
	for m in domain as []string {
		page.enable(m)
	}
}

pub fn (mut page Page) disable(domain Strings, msg MessageParams) {
	if domain.type_name() == 'string' {
		domain_str := domain as string
		page.send_or_noop('${domain_str}.disable', msg)
		idx := page.deps.index(domain_str)
		if page.deps.contains(domain_str) && idx != -1 {
			page.deps.delete(idx)
		}
		return
	}
	for m in domain as []string {
		page.disable(m)
	}
}

@[params]
pub struct PageNavigateParams {
pub:
	url             string    @[json: 'url']
	referrer        ?string   @[json: 'referrer']
	transition_type ?string   @[json: 'transitionType']
	frame_id        ?string   @[json: 'frameId']
	referrer_policy ?string   @[json: 'referrerPolicy']
	cb              EventFunc = unsafe { nil } @[json: '-']
	ref             voidptr   @[json: '-']
}

pub fn (mut page Page) navigate_opt(url string, opts PageNavigateParams) !Result {
	params := struct_to_json_any(PageNavigateParams{ ...opts, url: url })!.as_map()
	return page.send('Page.navigate', params: params)!
}

@[noreturn]
fn (mut page Page) noop(err IError) {
	page.browser.noop(err)
}

pub fn (mut page Page) navigate(url string, opts PageNavigateParams) Result {
	return page.navigate_opt(url, opts) or { page.noop(err) }
}

pub fn (mut page Page) from_file(pathfile string, opts PageNavigateParams) Result {
	mut file := get_file_url(pathfile) or { page.noop(err) }
	return page.navigate(file, opts)
}

pub fn (mut page Page) from_html(html_str string, opts PageNavigateParams) Result {
	return page.navigate('data:text/html,${urllib.path_escape(html_str)}', opts)
}

pub fn (mut page Page) wait_until_opt(params MessageParams) ! {
	mut method := params.method
	if method == '' {
		method = 'Page.loadEventFired'
	}
	page.send_event(method, params)!
	page.off_all()
}

pub fn (mut page Page) wait_until(params MessageParams) {
	page.wait_until_opt(params) or { page.noop(err) }
}
