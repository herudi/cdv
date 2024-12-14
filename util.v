module cdv

import os
import net.http
import time
import strings

const def_timeout = 2 * time.second

fn find_executable(name string) string {
	return os.find_abs_path_of_executable(name) or { '' }
}

pub fn find_between(args ...string) string {
	return strings.find_between_pair_string(...args)
}

pub fn fetch_data(url string, method http.Method) !http.Response {
	return http.Request{
		url:          url
		method:       method
		read_timeout: def_timeout
	}.do()!
}

fn get_version_hell(url string) http.Response {
	return fetch_data(url, .get) or {
		http.Response{
			status_code: 500
		}
	}
}

fn get_base_url(opts Config) string {
	if opts.base_url != '' {
		return opts.base_url
	}
	proto := if opts.secure { 'https' } else { 'http' }
	return '${proto}://${opts.host}:${opts.port}'
}
