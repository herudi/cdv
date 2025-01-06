module cdv

import io
import encoding.base64
import x.json2 as json

@[params]
pub struct IOStreamParams {
pub:
	writer ?io.Writer
	reader ?io.Reader
	offset ?int
	size   ?int
}

pub fn (mut page Page) handle_stream_opt(handle string, opts IOStreamParams) ! {
	for {
		res := page.io_read(handle, offset: opts.offset, size: opts.size)
		mut buf := []u8{}
		if res.base64_encoded {
			buf = base64.decode(res.data)
		} else {
			buf = res.data.bytes()
		}
		if mut writer := opts.writer {
			writer.write(buf)!
		}
		if mut reader := opts.reader {
			reader.read(mut buf)!
		}
		if res.eof {
			page.io_close(handle)
			break
		}
	}
}

pub fn (mut page Page) handle_stream(handle string, opts IOStreamParams) {
	page.handle_stream_opt(handle, opts) or { page.noop(err) }
}

@[params]
pub struct IOReadParams {
pub:
	offset ?int
	size   ?int
}

pub struct IORead {
pub:
	base64_encoded bool
	data           string
	eof            bool
}

pub fn (mut page Page) io_read_opt(handle string, opts IOReadParams) !IORead {
	mut params := map[string]json.Any{}
	params['handle'] = handle
	if offset := opts.offset {
		params['offset'] = offset
	}
	if size := opts.size {
		params['size'] = size
	}
	res := page.send_or_noop('IO.read', params: params).result
	return IORead{
		base64_encoded: res['base64Encoded'] or { false }.bool()
		data:           res['data']!.str()
		eof:            res['eof']!.bool()
	}
}

pub fn (mut page Page) io_read(handle string, opts IOReadParams) IORead {
	return page.io_read_opt(handle, opts) or { page.noop(err) }
}

pub fn (mut page Page) io_close(handle string) {
	page.send_or_noop('IO.close',
		params: {
			'handle': handle
		}
	)
}
