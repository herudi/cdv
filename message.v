module cdv

import x.json2 as json

pub enum MessageType {
	command
	event
}

@[params]
pub struct ParamRef {
pub:
	ref voidptr
}

@[params]
pub struct ParamTimeout {
pub:
	timeout i64 = def_timeout
}

@[params]
pub struct ParamRefTimeout {
pub:
	timeout i64 = def_timeout
	ref     voidptr
}

pub type EventFunc = fn (mut msg Message, ref voidptr) !bool

@[params]
pub struct MessageParams {
pub:
	id         int = -1
	method     string
	params     ?map[string]json.Any
	session_id ?string     @[json: 'sessionId']
	typ        MessageType = .command @[json: '-']
	cb         EventFunc   = unsafe { nil }   @[json: '-']
	ref        voidptr     @[json: '-']
	timeout    i64 = ch_timeout         @[json: '-']
}

fn (params MessageParams) create_timeout(tt i64) i64 {
	if params.timeout == ch_timeout {
		return tt
	}
	return params.timeout
}

pub struct Message {
pub:
	method     string
	session_id string
pub mut:
	params map[string]json.Any
	page   &Page = unsafe { nil }
}

pub fn (msg Message) has(m string) bool {
	return m != '' && (m == msg.method || map_method[m] == msg.method)
}

pub fn (msg Message) done() bool {
	return cdv_msg_done
}

pub fn (msg Message) next() bool {
	return cdv_msg_next
}

pub fn (mut msg Message) get_request() !Request {
	params := msg.params.clone()
	if request := params['request'] {
		mut info := json.decode[RequestInfo](params.str())!
		mut req := json.decode[Request](request.json_str())!
		req.has_post_data = req.has_post_data_ or { false }
		req.info = &info
		req.page = msg.page
		return req
	}
	return error('cannot find "params.request"')
}

pub fn (mut msg Message) get_response() !Response {
	params := msg.params.clone()
	if response := params['response'] {
		mut info := json.decode[ResponseInfo](params.str())!
		mut res := json.decode[Response](response.json_str())!
		res.info = &info
		res.page = msg.page
		return res
	}
	return error('cannot find "params.response"')
}
