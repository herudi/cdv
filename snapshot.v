module cdv

import os

@[params]
pub struct SnapshotParams {
pub:
	format string = 'mhtml'
	path   ?string
}

pub struct Snapshot {
pub:
	data string
}

pub fn (mut page Page) snapshot_opt(opts SnapshotParams) !Snapshot {
	params := struct_to_json_any(opts)!.as_map()
	res := page.send('Page.captureSnapshot', params: params)!.result
	if data := res['data'] {
		data_str := data.str()
		if path := opts.path {
			os.write_file(path, data_str)!
		}
		return Snapshot{
			data: data_str
		}
	}
	return error('data snapshot not found')
}

pub fn (mut page Page) snapshot(opts SnapshotParams) Snapshot {
	return page.snapshot_opt(opts) or { page.noop(err) }
}
