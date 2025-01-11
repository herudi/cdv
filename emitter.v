module cdv

@[params]
pub struct ParamRef {
pub:
	ref voidptr
}

pub struct EmitData {
pub:
	method string
	cb     EventFunc = unsafe { nil }
	ref    voidptr
}

pub fn (mut bwr Browser) on(method Strings, cb EventFunc, params ParamRef) {
	if method.type_name() == 'string' {
		mut mtd := method as string
		if mtd in map_method {
			mtd = map_method[mtd]
		}
		bwr.emits << EmitData{mtd, cb, params.ref}
		return
	}
	for m in method as []string {
		bwr.on(m, cb, params)
	}
}

pub fn (mut bwr Browser) off_all() {
	bwr.emits = []EmitData{}
}

pub fn (mut bwr Browser) emit(method string, mut msg Message) bool {
	for emit in bwr.emits {
		if emit.method == method || emit.method == '*' {
			return emit.cb(mut msg, emit.ref) or { bwr.noop(err) }
		}
	}
	return false
}

// for page
pub fn (mut page Page) emit(method string, mut msg Message) bool {
	return page.browser.emit(method, mut msg)
}

struct DataMessagePage {
	cb  EventFunc = unsafe { nil }
	ref voidptr
mut:
	page &Page = unsafe { nil }
}

pub fn (mut page Page) on(method Strings, cb EventFunc, params ParamRef) {
	mut data := &DataMessagePage{cb, params.ref, page}
	page.browser.on(method, fn (mut msg Message, mut data DataMessagePage) !bool {
		msg.page = data.page
		return data.cb(mut msg, data.ref)!
	}, ref: data)
}

pub fn (mut page Page) off_all() {
	page.browser.off_all()
}
