module cdv

@[heap]
pub struct Selector {
pub mut:
	elem   string
	page   &Page = unsafe { nil }
	var_id int   = 1
	is_arr bool
	is_all bool
}

fn (mut page Page) c_selector(query string, is_all bool) !&Selector {
	suffix := if is_all { 'All' } else { '' }
	mut id := page.var_id++
	elem := '$${id}'
	exp := 'let ${elem} = document.querySelector${suffix}(`${query}`);${elem}'
	page.send('Runtime.evaluate',
		params: {
			'expression': exp
		}
	)!
	return &Selector{
		page:   page
		elem:   elem
		is_all: is_all
	}
}

pub fn (mut page Page) selector(query string) !&Selector {
	return page.c_selector(query, false)!
}

pub fn (mut page Page) selectors(query string) !&Selector {
	return page.c_selector(query, true)!
}

pub fn (mut s Selector) c_selector(query string, is_all bool) !&Selector {
	suffix := if is_all { 'All' } else { '' }
	mut id := s.var_id++
	elem := '$${s.page.var_id}_${id}'
	s.eval('let ${elem} = document.querySelector${suffix}(`${query}`);${elem}')!
	return &Selector{
		page:   s.page
		elem:   elem
		var_id: s.var_id
		is_all: is_all
	}
}

pub fn (mut s Selector) selector(query string) !&Selector {
	return s.c_selector(query, false)!
}

pub fn (mut s Selector) selectors(query string) !&Selector {
	return s.c_selector(query, true)!
}

pub fn (mut s Selector) eval(exp string) !Result {
	return s.page.send('Runtime.evaluate',
		params: {
			'expression': exp
		}
	)!
}

pub fn (mut s Selector) mutate(name string, js_fn string) !&Selector {
	mut elem := s.elem
	mut prefix := ''
	if !s.is_arr {
		prefix = '${elem} = Array.from(${elem});'
		s.is_arr = true
	}
	s.eval('${prefix}${elem} = ${elem}.${name}(${js_fn});${elem}')!
	return s
}

pub fn (mut s Selector) find(js_fn string) !&Selector {
	return s.mutate('find', js_fn)!
}

pub fn (mut s Selector) at(idx int) !&Selector {
	return s.find('(_, i) => i === ${idx}')!
}

pub fn (mut s Selector) map_to(js_fn string) !&Selector {
	return s.mutate('map', js_fn)!
}

pub fn (mut s Selector) filter(js_fn string) !&Selector {
	return s.mutate('filter', js_fn)!
}

pub fn (mut s Selector) eval_str(expression string) !string {
	res := s.eval(expression)!.result
	if js_error := res['exceptionDetails'] {
		return error(js_error.prettify_json_str())
	}
	return res['result']!.as_map()['value'] or { '' }.str()
}

pub fn (mut s Selector) inner_html() !string {
	return s.eval_str('${s.elem}.innerHTML')!
}

pub fn (mut s Selector) text_content() !string {
	return s.eval_str('${s.elem}.textContent')!
}

pub fn (mut s Selector) str() string {
	return s.inner_html() or { '' }
}

pub fn (mut s Selector) set_value(data string) ! {
	s.eval('${s.elem}.value = `${data}`')!
}

pub fn (mut s Selector) get_value() !string {
	return s.eval_str('${s.elem}.value')!
}

pub fn (mut s Selector) click() ! {
	s.eval('${s.elem}.click()')!
}
