module cdv

import x.json2 as json

pub struct RequestInfo {
pub:
	request_id              string @[json: 'requestId']
	loader_id               string @[json: 'loaderId']
	document_url            string @[json: 'documentURL']
	timestamp               f64
	wall_time               f64 @[json: 'wallTime']
	initiator               json.Any
	redirect_has_extra_info bool      @[json: 'redirectHasExtraInfo']
	redirect_response       ?json.Any @[json: 'redirectResponse']
	typ                     ?string   @[json: 'type']
	frame_id                ?string   @[json: 'frameId']
	has_user_gesture        ?bool     @[json: 'hasUserGesture']
}

pub struct Request {
pub:
	url                string
	method             string
	headers            json.Any
	url_fragment       ?string   @[json: 'urlFragment']
	has_post_data_     ?bool     @[json: 'hasPostData']
	post_data_entries  ?json.Any @[json: 'postDataEntries']
	mixed_content_type ?string   @[json: 'mixedContentType']
	initial_priority   string    @[json: 'initialPriority']
	referrer_policy    string    @[json: 'referrerPolicy']
	is_link_preload    ?bool     @[json: 'isLinkPreload']
	trust_token_params ?json.Any @[json: 'trustTokenParams']
	is_same_site       ?bool     @[json: 'isSameSite']
pub mut:
	info          &RequestInfo = unsafe { nil } @[json: '-']
	has_post_data bool         @[json: '-']
}

pub type EventRequest = fn (mut req Request) !

pub type EventRequestRef = fn (mut req Request, ref voidptr) !

struct DataRequest {
	cb     EventRequest    = unsafe { nil }
	cb_ref EventRequestRef = unsafe { nil }
mut:
	ref voidptr
}

fn (mut page Page) build_on_request(cb EventRequest, cb_ref EventRequestRef, ref voidptr) &DataRequest {
	mut data := &DataRequest{
		cb:     cb
		cb_ref: cb_ref
		ref:    ref
	}
	page.on('Network.requestWillBeSent', fn (msg Message, mut data DataRequest) ! {
		params := msg.params.clone()
		mut info := json.decode[RequestInfo](params.str())!
		mut req := json.decode[Request](params['request']!.json_str())!
		req.has_post_data = req.has_post_data_ or { false }
		req.info = &info
		if !isnil(data.cb) {
			data.cb(mut req)!
		} else {
			data.cb_ref(mut req, data.ref)!
		}
	}, ref: data)
	return data
}

pub fn (mut page Page) on_request(cb EventRequest) &DataRequest {
	return page.build_on_request(cb, unsafe { nil }, unsafe { nil })
}

pub fn (mut page Page) on_request_ref(cb EventRequestRef, ref voidptr) &DataRequest {
	return page.build_on_request(unsafe { nil }, cb, ref)
}

pub fn (mut page Page) get_request_post_data(request_id string) json.Any {
	post_data := page.send_panic('Network.getRequestPostData',
		params: {
			'requestId': request_id
		}
	).result['postData'] or { json.Any{} }
	return post_data
}