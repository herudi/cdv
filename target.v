module cdv

import x.json2 as json

@[params]
pub struct BrowserContextParams {
pub:
	dispose_on_detach                     ?bool     @[json: 'disposeOnDetach']
	proxy_server                          ?string   @[json: 'proxyServer']
	proxy_bypass_list                     ?string   @[json: 'proxyBypassList']
	origins_with_universal_network_access ?[]string @[json: 'originsWithUniversalNetworkAccess']
}

pub fn (mut bwr Browser) create_browser_context_opt(opts BrowserContextParams) !&Browser {
	params := bwr.struct_to_json_any(opts).as_map()
	res := bwr.send_or_noop('Target.createBrowserContext', params: params).result
	if ctx_id := res['browserContextId'] {
		return &Browser{
			...bwr
			browser_context_id: ctx_id.str()
		}
	}
	return error('browser context id not found')
}

pub fn (mut bwr Browser) create_browser_context(opts BrowserContextParams) &Browser {
	return bwr.create_browser_context_opt(opts) or { bwr.noop(err) }
}

@[params]
pub struct ExposeDevToolsProtocolParams {
pub:
	binding string = 'cdp'
}

pub fn (mut page Page) expose_devtools_protocol(opts ExposeDevToolsProtocolParams) {
	page.send_or_noop('Target.exposeDevToolsProtocol',
		params: {
			'targetId':    page.target_id
			'bindingName': opts.binding
		}
	)
}

pub struct DiscoverTargetsParams {
pub:
	discover bool
	filter   ?[]json.Any
}

pub fn (mut bwr Browser) discover_targets(discover bool, opts DiscoverTargetsParams) {
	params := bwr.struct_to_json_any(DiscoverTargetsParams{ ...opts, discover: discover }).as_map()
	bwr.send_or_noop('Target.setDiscoverTargets', params: params)
}

pub struct RemoteLocation {
pub:
	host string
	port int
}

pub fn (mut bwr Browser) remote_locations(locs []RemoteLocation) {
	locations := bwr.struct_to_json_any(locs)
	bwr.send_or_noop('Target.setRemoteLocations',
		params: {
			'locations': locations
		}
	)
}

pub struct TargetInfo {
pub:
	target_id          string  @[json: 'targetId']
	typ                string  @[json: 'type']
	title              string  @[json: 'title']
	url                string  @[json: 'url']
	attached           bool    @[json: 'attached']
	opener_id          ?string @[json: 'openerId']
	can_access_opener  ?bool   @[json: 'canAccessOpener']
	opener_frame_id    ?string @[json: 'openerFrameId']
	browser_context_id ?string @[json: 'browserContextId']
	subtype            ?string @[json: 'subtype']
}

pub fn (mut page Page) get_info() TargetInfo {
	info := page.send_or_noop('Target.getTargetInfo',
		params: {
			'targetId': page.target_id
		}
	).result['targetInfo'] or { json.Any{} }.json_str()
	return json.decode[TargetInfo](info) or { page.noop(err) }
}
