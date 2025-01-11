module cdv

import x.json2 as json

pub struct Console {
pub mut:
	typ                  string                @[json: 'type']
	execution_context_id int                   @[json: 'executionContextId']
	timestamp            f64                   @[json: 'timestamp']
	stack_trace          ?json.Any             @[json: 'stackTrace']
	context              ?string               @[json: 'context']
	args                 []RuntimeRemoteObject @[json: '-']
	page                 &Page = unsafe { nil }                 @[json: '-']
	index                int                   @[json: '-']
}

pub type EventConsole = fn (mut csl Console) !bool

pub type EventConsoleRef = fn (mut csl Console, ref voidptr) !bool

pub struct DataConsole {
pub:
	cb     EventConsole    = unsafe { nil }
	cb_ref EventConsoleRef = unsafe { nil }
pub mut:
	ref   voidptr
	page  &Page = unsafe { nil }
	index int
}

fn (mut page Page) build_on_console(mut data DataConsole) {
	page.on('console', fn (mut msg Message, mut data DataConsole) !bool {
		mut params := msg.params.clone()
		mut csl := json.decode[Console](params.str())!
		mut args := []RuntimeRemoteObject{}
		arr := params['args']!.arr()
		for arg in arr {
			json_str := arg.json_str()
			args << json.decode[RuntimeRemoteObject](json_str)!
		}
		csl.args = args
		csl.page = msg.page
		csl.index = data.index
		data.index++
		if !isnil(data.cb) {
			return data.cb(mut csl)!
		}
		return data.cb_ref(mut csl, data.ref)!
	}, ref: data)
}

pub fn (mut page Page) on_console(cb EventConsole) {
	mut data := &DataConsole{
		cb: cb
	}
	page.build_on_console(mut data)
}

pub fn (mut page Page) on_console_ref(cb EventConsoleRef, ref voidptr) {
	mut data := &DataConsole{
		cb_ref: cb
		ref:    ref
	}
	page.build_on_console(mut data)
}

pub fn (_ Console) done() bool {
	return cdv_msg_done
}

pub fn (_ Console) next() bool {
	return cdv_msg_next
}
