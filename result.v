module cdv

import encoding.base64
import x.json2 as json
import os

pub enum ResultState {
	pending
	resolved
}

pub struct Result {
pub mut:
	state ResultState = .resolved
pub:
	method string
	id     int
	raw    string
	th     thread !Result
}

fn str_to_map(s string) map[string]json.Any {
	return json.decode[json.Any](s) or {
		map[string]json.Any{}
	}.as_map()
}

pub fn (res Result) as_map() map[string]json.Any {
	return str_to_map(res.raw)
}

pub fn (res Result) str() string {
	return res.raw
}

pub fn (res Result) json[T]() !T {
	return json.decode[T](res.raw)!
}

const save_file_methods = ['Page.captureScreenshot', 'Page.printToPDF']

pub fn (res Result) save(path string) ! {
	result := res.as_map()['result']!.as_map()
	mut buf, mut is_save := []u8{}, false
	if save_file_methods.contains(res.method) {
		buf = base64.decode(result['data']!.str())
		is_save = true
	}
	if is_save {
		mut f := os.create(path)!
		defer {
			f.close()
		}
		f.write(buf)!
		return
	}
	return error('cannot save from method "${res.method}"')
}

pub fn (res Result) result() map[string]json.Any {
	data := res.as_map()
	if result := data['result'] {
		return result.as_map()
	}
	return data
}

pub fn (res Result) result_json[T]() !T {
	data := res.as_map()
	if result := data['result'] {
		return json.decode[T](result.json_str())
	}
	return error('cannot find result')
}

pub fn (res Result) wait() !Result {
	if res.state == .pending {
		return res.th.wait()!
	}
	return res
}
