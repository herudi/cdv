module cdv

import x.json2 as json

@[params]
pub struct Cookie {
pub mut:
	name          string
	value         string
	url           ?string
	domain        ?string
	path          ?string
	secure        ?bool
	http_only     ?bool                @[json: 'httpOnly']
	same_site     ?string              @[json: 'sameSite']
	expires       ?i64                 @[json: 'expires']
	same_party    ?bool                @[json: 'sameParty']
	source_port   ?int                 @[json: 'sourcePort']
	partition_key ?map[string]json.Any @[json: 'partitionKey']
}

pub fn (mut page Page) set_cookie(name string, value string, params Cookie) {
	cookie := page.struct_to_json_any(Cookie{ ...params, name: name, value: value }).as_map()
	page.send_panic('Network.setCookie', params: cookie)
}

pub fn (mut page Page) delete_cookie(name string, params Cookie) {
	cookie := page.struct_to_json_any(Cookie{ ...params, name: name }).as_map()
	page.send_panic('Network.deleteCookies', params: cookie)
}

pub fn (mut page Page) clear_browser_cookie() {
	page.send_panic('Network.clearBrowserCookies')
}

pub fn (mut page Page) set_cookies(cookies []Cookie) {
	my_cookies := page.struct_to_json_any(cookies)
	page.send_panic('Network.setCookies',
		params: {
			'cookies': my_cookies
		}
	)
}

@[params]
pub struct GetCookiesParams {
pub:
	urls ?[]string
}

pub fn (mut page Page) get_cookies(opts GetCookiesParams) []Cookie {
	mut obj := map[string]json.Any{}
	if urls := opts.urls {
		obj['urls'] = urls.map(json.Any(it))
	}
	arr := page.send_panic('Network.getCookies', params: obj).result['cookies'] or { json.Any{} }.arr()
	mut cookies := []Cookie{}
	for cookie in arr {
		ck_map := cookie.as_map()
		mut ck := Cookie{
			name:  ck_map['name'] or { '' }.str()
			value: ck_map['value'] or { '' }.str()
		}
		if url := ck_map['url'] {
			ck.url = url.str()
		}
		if domain := ck_map['domain'] {
			ck.domain = domain.str()
		}
		if path := ck_map['path'] {
			ck.path = path.str()
		}
		if secure := ck_map['secure'] {
			ck.secure = secure.bool()
		}
		if http_only := ck_map['httpOnly'] {
			ck.http_only = http_only.bool()
		}
		if same_site := ck_map['sameSite'] {
			ck.same_site = same_site.str()
		}
		if expires := ck_map['expires'] {
			ck.expires = expires.i64()
		}
		if same_party := ck_map['sameParty'] {
			ck.same_party = same_party.bool()
		}
		if source_port := ck_map['sourcePort'] {
			ck.source_port = source_port.int()
		}
		if partition_key := ck_map['partitionKey'] {
			ck.partition_key = partition_key.as_map()
		}
		cookies << ck
	}

	return cookies
}
