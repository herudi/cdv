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
	page          &Page        = unsafe { nil }        @[json: '-']
	has_post_data bool         @[json: '-']
	index         int          @[json: '-']
}

pub type EventRequest = fn (mut req Request) !bool

pub type EventRequestRef = fn (mut req Request, ref voidptr) !bool

pub struct DataRequest {
pub:
	cb     EventRequest    = unsafe { nil }
	cb_ref EventRequestRef = unsafe { nil }
pub mut:
	ref     voidptr
	request ?Request
	index   int
}

fn (mut page Page) build_on_request(mut data DataRequest) {
	page.on('request', fn (mut msg Message, mut data DataRequest) !bool {
		mut req := msg.get_request()!
		req.index = data.index
		data.index++
		if !isnil(data.cb) {
			return data.cb(mut req)!
		}
		return data.cb_ref(mut req, data.ref)!
	}, ref: data)
}

pub fn (mut page Page) on_request(cb EventRequest) {
	mut data := &DataRequest{
		cb: cb
	}
	page.build_on_request(mut data)
}

pub fn (mut page Page) on_request_ref(cb EventRequestRef, ref voidptr) {
	mut data := &DataRequest{
		cb_ref: cb
		ref:    ref
	}
	page.build_on_request(mut data)
}

pub fn (mut req Request) get_post_data() json.Any {
	req_id := req.info.request_id
	post_data := req.page.send_or_noop('Network.getRequestPostData',
		params: {
			'requestId': req_id
		}
	).result['postData'] or { json.Any{} }
	return post_data
}

pub fn (req Request) done() bool {
	return cdv_msg_done
}

pub fn (req Request) next() bool {
	return cdv_msg_next
}

pub fn (mut req Request) redirect_response() ?Response {
	mut info := req.info
	if resp := info.redirect_response {
		mut res := json.decode[Response](resp.json_str()) or { req.page.noop(err) }
		res.info = &ResponseInfo{
			request_id: info.request_id
			loader_id:  info.loader_id
			timestamp:  info.timestamp
			typ:        info.typ
			frame_id:   info.frame_id
		}
		res.page = req.page
		return res
	}
	return none
}

pub fn (mut page Page) wait_for_request(cb EventRequest) ?Request {
	mut data := &DataRequest{
		cb: cb
	}
	page.on_request_ref(fn (mut req Request, mut data DataRequest) !bool {
		is_done := data.cb(mut req)!
		if is_done {
			data.request = req
		}
		return is_done
	}, data)
	page.wait_until()
	return data.request
}

pub fn (mut page Page) wait_for_request_ref(cb EventRequestRef, ref voidptr) ?Request {
	mut data := &DataRequest{
		cb_ref: cb
		ref:    ref
	}
	page.on_request_ref(fn (mut req Request, mut data DataRequest) !bool {
		is_done := data.cb_ref(mut req, data.ref)!
		if is_done {
			data.request = req
		}
		return is_done
	}, data)
	page.wait_until()
	return data.request
}
