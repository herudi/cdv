module cdv

import x.json2 as json
import encoding.base64

pub struct ResponseInfo {
pub:
	request_id     string @[json: 'requestId']
	loader_id      string @[json: 'loaderId']
	timestamp      f64
	has_extra_info bool    @[json: 'hasExtraInfo']
	typ            ?string @[json: 'type']
	frame_id       ?string @[json: 'frameId']
}

pub struct Response {
pub:
	url                            string
	status                         int
	status_text                    string @[json: 'statusText']
	headers                        json.Any
	mime_type                      string @[json: 'mimeType']
	charset                        string
	request_headers                ?json.Any @[json: 'requestHeaders']
	connection_reused              bool      @[json: 'connectionReused']
	connection_id                  f64       @[json: 'connectionId']
	remote_ip_address              ?string   @[json: 'remoteIPAddress']
	remote_port                    ?int      @[json: 'remotePort']
	from_disk_cache                ?bool     @[json: 'fromDiskCache']
	from_service_worker            ?bool     @[json: 'fromServiceWorker']
	from_prefetch_cache            ?bool     @[json: 'fromPrefetchCache']
	from_early_hints               ?bool     @[json: 'fromEarlyHints']
	service_worker_router_info     ?json.Any @[json: 'serviceWorkerRouterInfo']
	encoded_data_length            f64       @[json: 'encodedDataLength']
	timing                         ?json.Any
	service_worker_response_source ?string   @[json: 'serviceWorkerResponseSource']
	response_time                  ?f64      @[json: 'responseTime']
	cache_storage_cache_name       ?string   @[json: 'cacheStorageCacheName']
	protocol                       ?string   @[json: 'protocol']
	alternate_protocol_usage       ?string   @[json: 'alternateProtocolUsage']
	security_details               ?json.Any @[json: 'securityDetails']
	security_state                 string    @[json: 'securityState']
pub mut:
	info &ResponseInfo = unsafe { nil } @[json: '-']
}

pub type EventResponse = fn (mut res Response) !

pub type EventResponseRef = fn (mut res Response, ref voidptr) !

struct DataResponse {
	cb     EventResponse    = unsafe { nil }
	cb_ref EventResponseRef = unsafe { nil }
mut:
	ref voidptr
}

fn (mut page Page) build_on_response(cb EventResponse, cb_ref EventResponseRef, ref voidptr) &DataResponse {
	mut data := &DataResponse{
		cb:     cb
		cb_ref: cb_ref
		ref:    ref
	}
	page.on('Network.responseReceived', fn (msg Message, mut data DataResponse) ! {
		params := msg.params.clone()
		mut info := json.decode[ResponseInfo](params.str())!
		mut res := json.decode[Response](params['response']!.json_str())!
		res.info = &info
		if !isnil(data.cb) {
			data.cb(mut res)!
		} else {
			data.cb_ref(mut res, data.ref)!
		}
	}, ref: data)
	return data
}

pub fn (mut page Page) on_response(cb EventResponse) &DataResponse {
	return page.build_on_response(cb, unsafe { nil }, unsafe { nil })
}

pub fn (mut page Page) on_response_ref(cb EventResponseRef, ref voidptr) &DataResponse {
	return page.build_on_response(unsafe { nil }, cb, ref)
}

pub fn (mut page Page) get_response_body(request_id string) json.Any {
	res_body := page.send_panic('Network.getResponseBody',
		params: {
			'requestId': request_id
		}
	).result
	if body := res_body['body'] {
		is_encoded := res_body['base64Encoded'] or { false }.bool()
		if is_encoded {
			return json.Any(base64.decode_str(body.str()))
		}
		return body
	}
	return json.Any{}
}
