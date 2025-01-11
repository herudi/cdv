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
	info  &ResponseInfo = unsafe { nil } @[json: '-']
	page  &Page         = unsafe { nil }         @[json: '-']
	index int           @[json: '-']
}

pub type EventResponse = fn (mut res Response) !bool

pub type EventResponseRef = fn (mut res Response, ref voidptr) !bool

pub struct DataResponse {
pub:
	cb     EventResponse    = unsafe { nil }
	cb_ref EventResponseRef = unsafe { nil }
pub mut:
	ref      voidptr
	response ?Response
	index    int
}

fn (mut page Page) build_on_response(mut data DataResponse) {
	page.on('response', fn (mut msg Message, mut data DataResponse) !bool {
		mut res := msg.get_response()!
		res.index = data.index
		data.index++
		if !isnil(data.cb) {
			return data.cb(mut res)!
		}
		return data.cb_ref(mut res, data.ref)!
	}, ref: data)
}

pub fn (mut page Page) on_response(cb EventResponse) {
	mut data := &DataResponse{
		cb: cb
	}
	page.build_on_response(mut data)
}

pub fn (mut page Page) on_response_ref(cb EventResponseRef, ref voidptr) {
	mut data := &DataResponse{
		cb_ref: cb
		ref:    ref
	}
	page.build_on_response(mut data)
}

pub fn (mut res Response) get_body() json.Any {
	req_id := res.info.request_id
	res_body := res.page.send_or_noop('Network.getResponseBody',
		params: {
			'requestId': req_id
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

pub fn (res Response) done() bool {
	return cdv_msg_done
}

pub fn (res Response) next() bool {
	return cdv_msg_next
}

pub fn (mut page Page) wait_for_response(cb EventResponse) ?Response {
	mut data := &DataResponse{
		cb: cb
	}
	page.on_response_ref(fn (mut res Response, mut data DataResponse) !bool {
		is_done := data.cb(mut res)!
		if is_done {
			data.response = res
		}
		return is_done
	}, data)
	page.wait_until()
	return data.response
}

pub fn (mut page Page) wait_for_response_ref(cb EventResponseRef, ref voidptr) ?Response {
	mut data := &DataResponse{
		cb_ref: cb
		ref:    ref
	}
	page.on_response_ref(fn (mut res Response, mut data DataResponse) !bool {
		is_done := data.cb_ref(mut res, data.ref)!
		if is_done {
			data.response = res
		}
		return is_done
	}, data)
	page.wait_until()
	return data.response
}
