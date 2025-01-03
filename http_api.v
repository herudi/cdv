module cdv

import net.http

@[params]
pub struct ApiOptions {
pub:
	target_id string
}

pub struct HttpApi {
pub:
	target_id string
	base_url  string
}

pub fn (mut bwr Browser) new_http_api() &HttpApi {
	return &HttpApi{
		target_id: bwr.target_id
		base_url:  bwr.base_url
	}
}

pub fn (api &HttpApi) get_version() !http.Response {
	return fetch_data('${api.base_url}/json/version', .get)!
}

pub fn (api &HttpApi) get_targets() !http.Response {
	return fetch_data('${api.base_url}/json/list', .get)!
}

pub fn (api &HttpApi) get_protocol() !http.Response {
	return fetch_data('${api.base_url}/json/protocol', .get)!
}

pub fn (api &HttpApi) get_active_tab(opts ApiOptions) !http.Response {
	target_id := if opts.target_id == '' { api.target_id } else { opts.target_id }
	return fetch_data('${api.base_url}/json/activate/${target_id}', .get)!
}

pub fn (api &HttpApi) get_close_tab(opts ApiOptions) !http.Response {
	target_id := if opts.target_id == '' { api.target_id } else { opts.target_id }
	return fetch_data('${api.base_url}/json/close/${target_id}', .get)!
}

pub fn (api &HttpApi) put_new_tab(url string) !http.Response {
	return fetch_data('${api.base_url}/json/new?${url}', .put)!
}
