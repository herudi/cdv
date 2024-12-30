module cdv

import x.json2 as json
import os

@[heap]
pub struct Element {
pub mut:
	page    &Page = unsafe { nil }
	data    string
	var_id  int
	node_id int
}

@[params]
pub struct ElementParams {
pub:
	node_id ?int
	data    ?string
}

pub fn (mut page Page) document_opt() !Element {
	node_id := page.send('DOM.getDocument')!.result['root']!.as_map()['nodeId']!.int()
	return Element{
		node_id: node_id
		page:    page
		data:    'document'
	}
}

pub fn (mut page Page) document() Element {
	return page.document_opt() or { page.noop(err) }
}

pub fn (mut page Page) selector_opt(s string, params ElementParams) !Element {
	root_id := params.node_id or { page.document().node_id }
	data := params.data or { 'document' }
	node_id := page.send('DOM.querySelector',
		params: {
			'nodeId':   json.Any(root_id)
			'selector': s
		}
	)!.result['nodeId']!.int()
	return Element{
		node_id: node_id
		page:    page
		data:    '${data}.querySelector(`${s}`)'
	}
}

pub fn (mut page Page) selector(s string, params ElementParams) Element {
	return page.selector_opt(s, params) or { page.noop(err) }
}

pub fn (mut page Page) selectors_opt(s string, params ElementParams) ![]Element {
	root_id := params.node_id or { page.document().node_id }
	data := params.data or { 'document' }
	node_ids := page.send('DOM.querySelectorAll',
		params: {
			'nodeId':   json.Any(root_id)
			'selector': s
		}
	)!.result['nodeIds']!.arr()
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

pub fn (mut page Page) selectors(s string, params ElementParams) []Element {
	return page.selectors_opt(s, params) or { page.noop(err) }
}

pub type EachCb = fn (mut elem Element, idx int) !

pub type FilterCb = fn (mut elem Element, idx int) !bool

pub fn (mut elems []Element) each(cb EachCb) {
	for i, mut elem in elems {
		cb(mut elem, i) or { elem.page.noop(err) }
	}
}

pub fn (mut elems []Element) find(cb FilterCb) ?Element {
	for i, mut elem in elems {
		stat := cb(mut elem, i) or { elem.page.noop(err) }
		if stat {
			return elem
		}
	}
	return none
}

pub fn (mut el Element) selector(s string) Element {
	return el.page.selector(s, node_id: el.node_id, data: el.data)
}

pub fn (mut el Element) selectors(s string) []Element {
	return el.page.selectors(s, node_id: el.node_id, data: el.data)
}

pub fn (mut el Element) files_opt(s string, paths []string) ! {
	file_id := el.selector(s).node_id
	mut files := []json.Any{}
	for path in paths {
		if !os.exists(path) {
			return error('pathfile not found')
		}
		if os.is_abs_path(path) {
			files << path
		} else {
			files << os.abs_path(path)
		}
	}
	el.page.send('DOM.setFileInputFiles',
		params: {
			'nodeId': file_id
			'files':  files
		}
	)!
}

pub fn (mut el Element) files(s string, paths []string) {
	el.files_opt(s, paths) or { el.page.noop(err) }
}

pub fn (mut el Element) file(s string, path string) {
	el.files(s, [path])
}

pub fn (mut el Element) get(args ...string) string {
	val := args.join('')
	return el.page.eval('${el.data}.${val}').str()
}

pub fn (mut el Element) set(args ...string) {
	val := args.join('')
	el.page.eval('${el.data}.${val}')
}

pub fn (mut el Element) value_from(name string, args ...string) string {
	if args.len == 0 {
		return el.get(name)
	}
	val := args.join('')
	el.set(name, '=', '`${val}`')
	return ''
}

pub fn (mut el Element) method_from(name string, args ...json.Any) string {
	val := args.str()
	return el.get('${name}(...${val})')
}

pub fn (mut el Element) input(s string, val string) {
	data := '${el.data}.querySelector(`${s}`)'
	el.page.eval('${data}.value = `${val}`')
}

pub fn (mut el Element) click(s string) {
	data := '${el.data}.querySelector(`${s}`)'
	el.page.eval('${data}.click()')
}

pub fn (mut el Element) outer_html(s ...string) string {
	return el.value_from('outerHTML', ...s)
}

pub fn (mut el Element) inner_html(s ...string) string {
	return el.value_from('innerHTML', ...s)
}

pub fn (mut el Element) text_content(s ...string) string {
	return el.value_from('textContent', ...s)
}

pub fn (mut el Element) value(s ...string) string {
	return el.value_from('value', ...s)
}

pub fn (mut el Element) attr(k string, args ...string) string {
	if args.len == 0 {
		return el.method_from('getAttribute', json.Any(k))
	}
	mut vals := []json.Any{}
	vals << json.Any(k)
	vals << args.map(json.Any(it))
	return el.method_from('setAttribute', ...vals)
}

pub fn (mut el Element) remove_attr(k string) {
	el.method_from('removeAttribute', json.Any(k))
}

pub fn (mut el Element) str() string {
	return el.outer_html()
}
