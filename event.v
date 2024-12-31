module cdv

import x.json2 as json

@[params]
pub struct RefParams {
pub:
	ref voidptr
}

pub type Request = map[string]json.Any

pub type EventRequest = fn (Request, voidptr) !

struct DataRequest {
	cb  EventRequest = unsafe { nil }
	ref voidptr
}

pub fn (mut page Page) on_request(cb EventRequest, params RefParams) {
	data := &DataRequest{cb, params.ref}
	page.on('Network.requestWillBeSent', fn (msg Message, data &DataRequest) ! {
		mut info := map[string]json.Any{}
		params := msg.params.clone()
		for k, v in params {
			if k != 'request' {
				info[k] = v
			}
		}
		mut req := params['request']!.as_map()
		req['info'] = info
		data.cb(Request(req), data.ref)!
	}, ref: data)
	unsafe {
		data.free()
	}
}

pub type Response = map[string]json.Any

pub type EventResponse = fn (Response, voidptr) !

struct DataResponse {
	cb  EventResponse = unsafe { nil }
	ref voidptr
}

pub fn (mut page Page) on_response(cb EventResponse, params RefParams) {
	data := &DataResponse{cb, params.ref}
	page.on('Network.responseReceived', fn (msg Message, data &DataResponse) ! {
		mut info := map[string]json.Any{}
		params := msg.params.clone()
		for k, v in params {
			if k != 'response' {
				info[k] = v
			}
		}
		mut res := params['response']!.as_map()
		res['info'] = info
		data.cb(Response(res), data.ref)!
	}, ref: data)
	unsafe {
		data.free()
	}
}
