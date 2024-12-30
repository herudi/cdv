module cdv

import os

@[params]
pub struct SnapshotParams {
pub:
	format string = 'mhtml'
}

pub struct Snapshot {
pub:
	data string
}

pub fn (mut page Page) snapshot_opt(opts SnapshotParams) !Snapshot {
	params := struct_to_map(opts)!
	res := page.send('Page.captureSnapshot', params: params)!.result
	if data := res['data'] {
		return Snapshot{
			data: data.str()
		}
	}
	return error('data not found')
}

pub fn (mut page Page) snapshot(opts SnapshotParams) Snapshot {
	return page.snapshot_opt(opts) or { page.noop(err) }
}

pub fn (mut page Page) save_as_mhtml(path string, opts SnapshotParams) {
	data := page.snapshot(SnapshotParams{ ...opts, format: 'mhtml' })
	data.save(path) or { page.noop(err) }
}

pub fn (sc Snapshot) save(path string) ! {
	os.write_file(path, sc.data)!
}
