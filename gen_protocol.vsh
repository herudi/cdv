import os
import x.json2 as json
import strings
import net.http

// update domain and mapper

const base_doc = 'https://chromedevtools.github.io/devtools-protocol/tot/'

const browser_proto_url = 'https://raw.githubusercontent.com/ChromeDevTools/devtools-protocol/refs/heads/master/json/browser_protocol.json'
const js_proto_url = 'https://raw.githubusercontent.com/ChromeDevTools/devtools-protocol/refs/heads/master/json/js_protocol.json'

const reps = ['IO', 'Io', 'DOM', 'Dom', 'CSS', 'Css', 'DB', 'Db', 'PDF', 'Pdf', 'CSP', 'Csp']
const rep_docs = ['\n', '\n//', "'", "'"]
const mutate_types = {
	'string':  'string'
	'object':  'map[string]json.Any'
	'integer': 'int'
	'array':   '[]json.Any'
	'number':  'f64'
	'boolean': 'bool'
}

fn to_snake_case(pascal_case string) string {
	str := pascal_case.replace_each(reps)
	mut arr := strings.split_capital(str)
	mut res := ''
	for i, data in arr {
		if data.len == 1 {
			res += data.to_lower()
		} else if i != 0 {
			res += '_${data}'.to_lower()
		} else {
			res += data.to_lower()
		}
	}
	return res.replace('.', '_')
}

fn build_params(name string, params_name_struct string, params_any json.Any, types map[string]string) !string {
	mut out := ''
	if params_any.str() != '' {
		params := params_any.arr()
		for p in params {
			param := p.as_map()
			param_name := param['name']!.str()
			is_opt := param['optional'] or { 'false' }.bool()
			quest := if is_opt { '?' } else { '' }
			required := if is_opt { '' } else { 'required;' }
			typ := param['type'] or {
				mut dd := param['\$ref'] or { '' }.str()
				if dd != '' && !dd.contains('.') {
					dd = '${name}.${dd}'
				}
				types[dd]
			}.str()
			mut def_types := mutate_types[typ]
			if mutate_types[typ] == '' {
				def_types = 'json.Any'
			}
			out += '${to_snake_case(param_name)} ${quest}${def_types} @[${required}json: "${param_name}"]\n'
		}
	}
	if out != '' {
		return '
			@[params]
			pub struct ${params_name_struct} {\n
				pub:
					${out}cb EventFunc = unsafe { nil } @[json: "-"]
					wait bool = true @[json: "-"]
					ref voidptr = unsafe { nil } @[json: "-"]
			}\n
		'
	}
	return out
}

fn get_domains() ![]json.Any {
	println('downloading from => ${browser_proto_url}\n')
	browser_proto := http.get(browser_proto_url)!.body
	println('downloading from => ${js_proto_url}\n')
	js_proto := http.get(js_proto_url)!.body

	mut proto := json.decode[json.Any](browser_proto)!.as_map()['domains']!.arr()
	js_proto_arr := json.decode[json.Any](js_proto)!.as_map()['domains']!.arr()

	proto << js_proto_arr
	return proto
}

fn update_domain() ! {
	mut domains := get_domains()!
	println('processing domain...\n')
	mut c_func := ''
	mut c_method := ''
	mut c_struct := ''
	mut g_types := map[string]string{}
	c_func += '
@[params]
pub struct ConfigCDVDomain {
	pub :
		enable bool = true
		deps []string
		enable_deps bool = true
}\n'

	for a in domains {
		data := a.as_map()
		name := data['domain']!.str()
		println('${name} done...')
		types_any := data['types'] or { '' }
		if types_any.str() != '' {
			mut types := types_any.arr()
			for t in types {
				typ_map := t.as_map()
				id := typ_map['id']!.str()
				typ := typ_map['type']!.str()
				g_types['${name}.${id}'] = typ
			}
		}
	}

	for a in domains {
		data := a.as_map()
		name := data['domain']!.str()
		deps := data['dependencies'] or { '' }.str()
		mut deps_str := ''
		if deps != '' {
			deps_str = '
				if opts.enable_deps {
					deps := if opts.deps.len == 0 { ${deps} } else { opts.deps }
					for dep in deps {
						if tab.is_inactive_deps(dep) {
							tab.send(dep + ".enable")!
							tab.deps << dep
						}
					}
				}				
			'
		}
		mut desc := data['description'] or { '' }.str()
		mut desc_str := ''
		if desc != '' {
			desc = desc.replace_each(rep_docs)
			desc_str += '// ${desc} see ${base_doc}${name}.'
		}
		c_func += '${desc_str}
pub struct ${name}Domain {
	pub mut:
		tab &Tab = unsafe { nil }
}\n'
		c_func += '
		// use ${name} domains.
pub fn (mut tab Tab) use_${to_snake_case(name)}(opts ConfigCDVDomain) !&${name}Domain {
		if opts.enable && tab.is_inactive_deps("${name}") {
			tab.send("${name}.enable")!
			tab.deps << "${name}"
		}
		${deps_str}
		return &${name}Domain{tab}
	}\n'
		mut commands_any := data['commands'] or { '' }
		if commands_any.str() != '' {
			mut commands := commands_any.arr()
			for b in commands {
				cmd := b.as_map()
				cmd_name := cmd['name'] or { '' }.str()
				if cmd_name != '' {
					method := '${name}.${cmd_name}'
					params_name := '${name}${cmd_name.capitalize()}Params'
					data_params := build_params(name, params_name, cmd['parameters'] or { '' },
						g_types)!
					c_method += "'${method}': MessageType.command,\n"
					snake_method := to_snake_case(cmd_name)
					mut cmd_desc := cmd['description'] or { '' }.str()
					mut cmd_desc_str := ''
					if cmd_desc != '' {
						cmd_desc = cmd_desc.replace_each(rep_docs)
						cmd_desc_str += '// ${cmd_desc} see ${base_doc}${name}/#method-${cmd_name}.'
					}
					if data_params != '' {
						c_struct += data_params
						c_func += '
${cmd_desc_str}
pub fn (mut p ${name}Domain) ${snake_method}(par ${params_name}) !Result {
	params := struct_to_map(par)!
	return p.tab.send("${method}", 
		params: params
		cb: par.cb
		wait: par.wait
		ref: par.ref
	)!
}\n'
					} else {
						c_func += '
${cmd_desc_str}
pub fn (mut p ${name}Domain) ${snake_method}(msg Message) !Result {
	return p.tab.send("${method}", msg)!
}\n'
					}
				}
			}
		}
		mut events_any := data['events'] or { json.Any('') }
		if events_any.str() != '' {
			mut events := events_any.arr()
			for b in events {
				ev := b.as_map()
				ev_name := ev['name'] or { '' }.str()
				if ev_name != '' {
					method := '${name}.${ev_name}'
					c_method += "'${method}': MessageType.event,\n"
					snake_method := to_snake_case(ev_name)
					mut ev_desc := ev['description'] or { '' }.str()
					mut ev_desc_str := ''
					if ev_desc != '' {
						ev_desc = ev_desc.replace_each(rep_docs)
						ev_desc_str += '// ${ev_desc} see ${base_doc}${name}/#event-${ev_name}.'
					}
					c_func += '
${ev_desc_str}
pub fn (mut p ${name}Domain) ${snake_method}(msg Message) !Result {return p.tab.send("${method}", msg)! }\n'
				}
			}
		}
	}

	out_domain := '
// this file generated by gen_protocol.vsh

module cdv

import x.json2 as json

pub const map_method = {
	${c_method}
}

fn (mut tab Tab) is_inactive_deps(name string) bool {
	return !tab.deps.contains(name) && name + ".enable" in map_method
}
fn struct_to_map[T](d T) !map[string]json.Any {
	return json.decode[json.Any](json.encode(d))!.as_map()
}
${c_struct}
${c_func}
'

	os.write_file(os.abs_path('./cdp.v'), out_domain)!

	os.execute('v fmt . -w')
}

update_domain()!

println('success update protocol.')
