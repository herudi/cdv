module cdv

import encoding.base64
import x.json2 as json
import os

pub enum ResultState {
	pending
	resolved
}

pub struct Result {
mut:
	state ResultState = .resolved
pub:
	method string
	id     int
	data   map[string]json.Any
	th     thread !Result
}

pub fn (res Result) as_map() map[string]json.Any {
	return res.data
}

pub fn (res Result) str() string {
	return res.data.str()
}

pub fn (res Result) json[T]() !T {
	return json.decode[T](res.str())!
}

pub fn (res Result) save(path string) ! {
	result := res.as_map()['result']!.as_map()
	data := result['data'] or { return error('cannot save file from method "${res.method}"') }
	buf := base64.decode(data.str())
	mut f := os.create(path)!
	defer {
		f.close()
	}
	f.write(buf)!
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
