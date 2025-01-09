module cdv

import x.json2 as json
import os

@[heap]
pub struct Element {
pub mut:
	data    string
	node_id int
	page    &Page = unsafe { nil }
	var_id  int
}

@[params]
pub struct ElementParams {
pub:
	node_id ?int
	data    ?string
}

pub fn (mut page Page) get_document_opt() !Element {
	node_id := page.send_warn('DOM.getDocument').result['root']!.as_map()['nodeId']!.int()
	return Element{
		node_id: node_id
		page:    page
		data:    'document'
	}
}

pub fn (mut page Page) get_document() Element {
	return page.get_document_opt() or { page.noop(err) }
}

pub fn (mut page Page) selector_opt(s string, params ElementParams) !Element {
	root_id := params.node_id or { page.get_document().node_id }
	data := params.data or { 'document' }
	node_id := page.send_warn('DOM.querySelector',
		params: {
			'nodeId':   json.Any(root_id)
			'selector': s
		}
	).result['nodeId']!.int()
	return Element{
		node_id: node_id
		page:    page
		data:    '${data}.querySelector(`${s}`)'
	}
}

pub fn (mut page Page) selector(s string, params ElementParams) Element {
	return page.selector_opt(s, params) or { page.noop(err) }
}

pub fn (mut page Page) selector_all_opt(s string, params ElementParams) ![]Element {
	root_id := params.node_id or { page.get_document().node_id }
	data := params.data or { 'document' }
	node_ids := page.send_warn('DOM.querySelectorAll',
		params: {
			'nodeId':   json.Any(root_id)
			'selector': s
		}
	).result['nodeIds']!.arr()
	mut elems := []Element{}
	for i, id in node_ids {
		node_id := id.int()
		elems << Element{
			node_id: node_id
			page:    page
			data:    '${data}.querySelectorAll(`${s}`)[${i}]'
		}
	}
	return elems
}

pub fn (mut page Page) selector_all(s string, params ElementParams) []Element {
	return page.selector_all_opt(s, params) or { page.noop(err) }
}

pub type EachCb = fn (mut elem Element, i int) !

pub type FindCb = fn (mut elem Element) !bool

pub fn (mut elems []Element) each(cb EachCb) {
	for i, mut elem in elems {
		cb(mut elem, i) or { elem.page.noop(err) }
	}
}

pub fn (mut elems []Element) find(cb FindCb) ?Element {
	for mut elem in elems {
		stat := cb(mut elem) or { elem.page.noop(err) }
		if stat {
			return elem
		}
	}
	return none
}

pub fn (mut el Element) eval(exp string, opts RuntimeEvaluateParams) json.Any {
	return el.page.eval(exp, opts)
}

pub fn (mut el Element) eval_fn(js_fn string, opts RuntimeEvaluateParams) json.Any {
	mut await_promise := opts.await_promise or { false }
	if !await_promise && js_fn.starts_with('async') {
		await_promise = true
	}
	exp := '(${js_fn})(${el.data})'
	return el.eval(exp, RuntimeEvaluateParams{ ...opts, await_promise: await_promise })
}

pub fn (mut el Element) selector(s string) Element {
	return el.page.selector(s, node_id: el.node_id, data: el.data)
}

pub fn (mut el Element) selector_all(s string) []Element {
	return el.page.selector_all(s, node_id: el.node_id, data: el.data)
}

pub fn (mut el Element) get(key string) string {
	return el.eval('${el.data}.${key}').str()
}

pub fn (mut el Element) write(key string) {
	el.eval('${el.data}.${key}')
}

pub fn (mut el Element) set_files_opt(paths []string) ! {
	mut files := []json.Any{}
	for path in paths {
		if !os.exists(path) {
			return error('${path} not found')
		}
		if os.is_abs_path(path) {
			files << path
		} else {
			files << os.abs_path(path)
		}
	}
	el.page.send_warn('DOM.setFileInputFiles',
		params: {
			'nodeId': el.node_id
			'files':  files
		}
	)
}

pub fn (mut el Element) set_files(paths []string) {
	el.set_files_opt(paths) or { el.page.noop(err) }
}

pub fn (mut el Element) set_file(path string) {
	el.set_files([path])
}

pub fn (mut el Element) get_file() string {
	remote := el.resolve_node()
	if object_id := remote.object_id {
		res := el.page.send_warn('DOM.getFileInfo',
			params: {
				'objectId': object_id
			}
		).result
		if path := res['path'] {
			return path.str()
		}
	}
	return ''
}

pub fn (mut el Element) click() {
	el.eval('${el.data}.click()')
}

pub fn (mut el Element) set_style(key string, val json.Any) {
	value := json.encode(val)
	el.write('style.${key}=${value}')
}

pub fn (mut el Element) set_outer_html(val string) {
	el.page.send_warn('DOM.setOuterHTML',
		params: {
			'nodeId':    el.node_id
			'outerHTML': val
		}
	)
}

pub fn (mut el Element) get_outer_html(opts WithBackendParams) string {
	params := el.page.struct_to_json_any(WithBackendParams{ ...opts, node_id: el.node_id }).as_map()
	res := el.page.send_warn('DOM.getOuterHTML', params: params).result
	if outer := res['outerHTML'] {
		return outer.str()
	}
	return ''
}

pub fn (mut el Element) set_inner_html(val string) {
	el.write('innerHTML=`${val}`')
}

pub fn (mut el Element) get_inner_html() string {
	return el.get('innerHTML')
}

pub fn (mut el Element) set_text_content(val string) {
	el.write('textContent=`${val}`')
}

pub fn (mut el Element) get_text_content() string {
	return el.get('textContent')
}

pub fn (mut el Element) set_value(val string) {
	el.write('value=`${val}`')
}

pub fn (mut el Element) get_value() string {
	return el.get('value')
}

pub fn (mut el Element) set_node_value(val string) {
	el.page.send_warn('DOM.setNodeValue',
		params: {
			'nodeId': el.node_id
			'value':  val
		}
	)
}

pub fn (mut el Element) get_node_value() string {
	return el.get('nodeValue')
}

pub fn (mut el Element) set_node_name(val string) {
	res := el.page.send_warn('DOM.setNodeName',
		params: {
			'nodeId': el.node_id
			'name':   val
		}
	).result
	if node_id := res['nodeId'] {
		el.node_id = node_id.int()
	}
}

pub fn (mut el Element) get_node_name() string {
	return el.get('nodeName')
}

pub fn (mut el Element) set_attr(key string, val string) {
	el.page.send_warn('DOM.setAttributeValue',
		params: {
			'nodeId': json.Any(el.node_id)
			'name':   key
			'value':  val
		}
	)
}

pub fn (mut el Element) get_attr(key string) string {
	return el.get('getAttribute(`${key}`)')
}

pub fn (mut el Element) remove_attr(key string) {
	el.write('removeAttribute(`${key}`)')
}

pub fn (mut el Element) get_attrs() []string {
	res := el.page.send_warn('DOM.getAttributes',
		params: {
			'nodeId': el.node_id
		}
	).result
	if attrs := res['attributes'] {
		return attrs.arr().map(it.str())
	}
	return []string{}
}

@[params]
pub struct WithBackendParams {
pub:
	node_id         ?int    @[json: 'nodeId']
	backend_node_id ?int    @[json: 'backendNodeId']
	object_id       ?string @[json: 'objectId']
}

pub fn (mut el Element) focus(opts WithBackendParams) {
	params := el.page.struct_to_json_any(WithBackendParams{ ...opts, node_id: el.node_id }).as_map()
	el.page.send_warn('DOM.focus', params: params)
}

@[params]
pub struct MoveToParams {
pub:
	insert_before ?Element
}

pub fn (mut el Element) move_to_opt(target Element, opts MoveToParams) !Element {
	node_id := el.node_id
	target_node_id := target.node_id
	mut params := map[string]json.Any{}
	params['nodeId'] = node_id
	params['targetNodeId'] = target_node_id
	if insert_before := opts.insert_before {
		params['insertBeforeNodeId'] = insert_before.node_id
	}
	res_node_id := el.page.send_warn('DOM.moveTo', params: params).result['nodeId']!.int()
	return Element{
		node_id: res_node_id
		page:    el.page
		data:    el.data
	}
}

pub fn (mut el Element) move_to(target Element, opts MoveToParams) Element {
	return el.move_to_opt(target, opts) or { el.page.noop(err) }
}

@[params]
pub struct NodeInfoParams {
pub:
	node_id         ?int    @[json: 'nodeId']
	backend_node_id ?int    @[json: 'backendNodeId']
	object_id       ?string @[json: 'objectId']
	depth           ?int
	pierce          ?bool
}

pub fn (mut el Element) get_info(opts NodeInfoParams) map[string]json.Any {
	params := el.page.struct_to_json_any(NodeInfoParams{ ...opts, node_id: el.node_id }).as_map()
	res := el.page.send_warn('DOM.describeNode', params: params).result
	if node := res['node'] {
		return node.as_map()
	}
	return map[string]json.Any{}
}

@[params]
pub struct ResolveNodeParams {
pub:
	node_id              ?int    @[json: 'nodeId']
	backend_node_id      ?int    @[json: 'backendNodeId']
	object_group         ?string @[json: 'objectGroup']
	execution_context_id ?int    @[json: 'executionContextId']
}

pub fn (mut el Element) resolve_node(opts ResolveNodeParams) RuntimeRemoteObject {
	params := el.page.struct_to_json_any(ResolveNodeParams{ ...opts, node_id: el.node_id }).as_map()
	res := el.page.send_warn('DOM.resolveNode', params: params).result
	if data := res['object'] {
		return json.decode[RuntimeRemoteObject](data.str()) or { el.page.noop(err) }
	}
	return RuntimeRemoteObject{}
}

pub fn (mut el Element) scroll_into_view() {
	el.eval_fn('(el) => {
		el.scrollIntoView({
			block: "center",
			inline: "center",
			behavior: "instant",
		});
	}')
}

pub fn (mut el Element) bounding_box() ?Viewport {
	res := el.eval_fn('(el) => {
		if (!(el instanceof Element)) {
			return null;
		}
		if (el.getClientRects().length === 0) {
			return null;
		}
		const rect = el.getBoundingClientRect();
		return { x: rect.x, y: rect.y, width: rect.width, height: rect.height };
	}')
	if res is json.Null {
		return none
	}
	return json.decode[Viewport](res.json_str()) or { el.page.noop(err) }
}

pub fn (mut el Element) screenshot(opts ScreenshotParams) Screenshot {
	el.scroll_into_view()
	mut clip := el.bounding_box() or { Viewport{} }
	size := el.eval_fn('() => {
		if (!window.visualViewport) {
			throw new Error("visualViewport not supported");
		}
		return [
			window.visualViewport.pageLeft,
			window.visualViewport.pageTop
		]
	}').arr().map(it.f64())
	clip.x = size[0] + (clip.x or { 0.0 })
	clip.y = size[1] + (clip.y or { 0.0 })
	if oc := opts.clip {
		if x := oc.x {
			clip.x = x + (clip.x or { 0.0 })
		}
		if y := oc.y {
			clip.y = y + (clip.y or { 0.0 })
		}
		if height := oc.height {
			clip.height = height
		}
		if width := oc.width {
			clip.width = width
		}
		if scale := oc.scale {
			clip.scale = scale
		}
	}
	return el.page.screenshot(ScreenshotParams{ ...opts, clip: clip })
}

pub fn (mut el Element) str() string {
	return el.get_outer_html()
}
