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
		bwr.emits << EmitData{method as string, cb, params.ref}
		return
	}
	for m in method as []string {
		bwr.on(m, cb, params)
	}
}

pub fn (mut bwr Browser) off(method Strings, cb EventFunc, params ParamRef) {
	if method.type_name() == 'string' {
		for i, emit in bwr.emits {
			if emit.method == (method as string) && params.ref == emit.ref {
				bwr.emits.delete(i)
			}
		}
		return
	}
	for m in method as []string {
		bwr.off(m, cb, params)
	}
}

pub fn (mut bwr Browser) off_all() {
	bwr.emits = []EmitData{}
}

pub fn (mut bwr Browser) emit(method string, msg Message) ! {
	for emit in bwr.emits {
		if emit.method == method || emit.method == '*' {
			emit.cb(msg, emit.ref)!
		}
	}
}

// for page
pub fn (mut page Page) emit(method string, msg Message) ! {
	page.browser.emit(method, msg)!
}

pub fn (mut page Page) on(method Strings, cb EventFunc, params ParamRef) {
	page.browser.on(method, cb, params)
}

pub fn (mut page Page) off(method Strings, cb EventFunc, params ParamRef) {
	page.browser.off(method, cb, params)
}

pub fn (mut page Page) off_all() {
	page.browser.off_all()
}
