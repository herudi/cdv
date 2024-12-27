module cdv

import x.json2 as json
import os
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

pub struct Viewport {
pub:
	x      ?f64
	y      ?f64
	width  ?f64
	height ?f64
	scale  ?f64
}

pub fn (mut bwr Browser) new_page() !&Page {
	mut target_id := ''
	if bwr.has_init {
		target_id = bwr.target_id
		bwr.has_init = false
	} else {
		new_target := bwr.send('Target.createTarget',
			params: {
				'url': 'about:blank'
			}
		)!.result
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
	page.enable(['Page', 'DOM', 'IO', 'Network', 'Runtime'])!
	return page
}

pub fn (mut page Page) send(method string, params MessageParams) !Result {
	id := page.get_next_id(params.id)
	return page.browser.send(method, MessageParams{ ...params, id: id, session_id: page.session_id })!
}

pub fn (mut page Page) send_event(method string, msg MessageParams) !Result {
	return page.send(method, MessageParams{ ...msg, typ: .event })!
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

pub fn (mut page Page) enable(domain Strings, msg MessageParams) ! {
	if domain.type_name() == 'string' {
		domain_str := domain as string
		if !page.deps.contains(domain_str) {
			page.send('${domain_str}.enable', msg)!
			page.deps << domain_str
		}
		return
	}
	for m in domain as []string {
		page.enable(m)!
	}
}

pub fn (mut page Page) disable(domain Strings, msg MessageParams) ! {
	if domain.type_name() == 'string' {
		domain_str := domain as string
		page.send('${domain_str}.disable', msg)!
		idx := page.deps.index(domain_str)
		if page.deps.contains(domain_str) && idx != -1 {
			page.deps.delete(idx)
		}
		return
	}
	for m in domain as []string {
		page.disable(m)!
	}
}

@[params]
pub struct PageNavigateParams {
pub:
	url             string  @[json: 'url']
	referrer        ?string @[json: 'referrer']
	transition_type ?string @[json: 'transitionType']
	frame_id        ?string @[json: 'frameId']
	referrer_policy ?string @[json: 'referrerPolicy']
}

pub fn (mut page Page) navigate(url string, opts PageNavigateParams) !Result {
	params := struct_to_map(PageNavigateParams{ ...opts, url: url })!
	return page.send('Page.navigate', params: params)!
}

pub fn (mut page Page) from_file(pathfile string, opts PageNavigateParams) !Result {
	mut file := pathfile
	if !os.exists(file) {
		return error('cannot find pathfile ${file}')
	}
	if !os.is_abs_path(file) {
		file = os.abs_path(file)
	}
	if !file.starts_with('file://') {
		file = 'file://${file}'
	}
	return page.navigate(file, opts)!
}

pub fn (mut page Page) from_html(html_str string, opts PageNavigateParams) !Result {
	return page.navigate('data:text/html,${urllib.path_escape(html_str)}', opts)!
}

pub fn (mut page Page) wait_until(params MessageParams) !Result {
	mut method := params.method
	if method == '' {
		method = 'Page.loadEventFired'
	}
	return page.send_event(method, params)!
}

pub struct RuntimeRemoteObject {
pub:
	typ                   string @[json: 'type']
	value                 json.Any
	subtype               string
	class_name            string              @[json: 'className']
	unserializable_value  string              @[json: 'unserializableValue']
	object_id             string              @[json: 'objectId']
	deep_serialized_value map[string]json.Any @[json: 'deepSerializedValue']
	custom_preview        map[string]json.Any @[json: 'customPreview']
	preview               map[string]json.Any
	description           string
}

@[params]
pub struct RuntimeEvaluateParams {
pub:
	expression                       string               @[json: 'expression']
	object_group                     ?string              @[json: 'objectGroup']
	include_command_line_api         ?bool                @[json: 'includeCommandLineAPI']
	silent                           ?bool                @[json: 'silent']
	context_id                       ?int                 @[json: 'contextId']
	return_by_value                  ?bool                @[json: 'returnByValue']
	generate_preview                 ?bool                @[json: 'generatePreview']
	user_gesture                     ?bool                @[json: 'userGesture']
	await_promise                    ?bool                @[json: 'awaitPromise']
	throw_on_side_effect             ?bool                @[json: 'throwOnSideEffect']
	timeout                          ?f64                 @[json: 'timeout']
	disable_breaks                   ?bool                @[json: 'disableBreaks']
	repl_mode                        ?bool                @[json: 'replMode']
	allow_unsafe_eval_blocked_by_csp ?bool                @[json: 'allowUnsafeEvalBlockedByCSP']
	unique_context_id                ?string              @[json: 'uniqueContextId']
	serialization_options            ?map[string]json.Any @[json: 'serializationOptions']
}

pub fn (mut page Page) eval_fn(js_fn string, opts RuntimeEvaluateParams) !json.Any {
	mut await_promise := opts.await_promise or { false }
	if !await_promise && js_fn.starts_with('async') {
		await_promise = true
	}
	exp := '(${js_fn})()'
	return page.eval(exp, RuntimeEvaluateParams{ ...opts, await_promise: await_promise })!
}

pub fn (mut page Page) eval(exp string, opts RuntimeEvaluateParams) !json.Any {
	return page.eval_op(exp, opts)!.value
}

pub fn (mut page Page) eval_op(exp string, opts RuntimeEvaluateParams) !RuntimeRemoteObject {
	params := struct_to_map(RuntimeEvaluateParams{
		...opts
		expression: exp
	})!
	result := page.send('Runtime.evaluate', params: params)!.result
	if js_error := result['exceptionDetails'] {
		return error(js_error.prettify_json_str())
	}
	data := result['result'] or { json.Any{} }.as_map()
	runtime_obj := RuntimeRemoteObject{
		typ:                   data['type'] or { '' }.str()
		value:                 data['value'] or { json.Any{} }
		subtype:               data['subtype'] or { '' }.str()
		class_name:            data['className'] or { '' }.str()
		unserializable_value:  data['unserializableValue'] or { '' }.str()
		object_id:             data['objectId'] or { '' }.str()
		deep_serialized_value: data['deepSerializedValue'] or { json.Any{} }.as_map()
		custom_preview:        data['customPreview'] or { json.Any{} }.as_map()
		preview:               data['preview'] or { json.Any{} }.as_map()
		description:           data['description'] or { '' }.str()
	}
	return runtime_obj
}
