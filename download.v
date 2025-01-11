module cdv

import x.json2 as json

@[params]
pub struct DownloadBehaviorParams {
pub:
	behavior           string
	browser_context_id ?string @[json: 'browserContextId']
	download_path      ?string @[json: 'downloadPath']
	events_enabled     ?bool   @[json: 'eventsEnabled']
}

pub fn (mut bwr Browser) set_download_behavior(behavior string, opts DownloadBehaviorParams) {
	params := bwr.struct_to_json_any(DownloadBehaviorParams{
		...opts
		behavior:           behavior
		browser_context_id: bwr.browser_context_id
	}).as_map()
	bwr.send_or_noop('Browser.setDownloadBehavior', params: params)
}

pub fn (mut bwr Browser) cancel_download(guid string) {
	mut params := map[string]json.Any{}
	params['guid'] = guid
	if ctx_id := bwr.browser_context_id {
		params['browserContextId'] = ctx_id
	}
	bwr.send_or_noop('Browser.cancelDownload', params: params)
}

pub struct DownloadProgress {
pub:
	guid           string
	total_bytes    f64 @[json: 'totalBytes']
	received_bytes f64 @[json: 'receivedBytes']
	state          string
pub mut:
	index int @[json: '-']
}

pub type EventDownloadProgress = fn (mut dp DownloadProgress) !bool

pub type EventDownloadProgressRef = fn (mut dp DownloadProgress, ref voidptr) !bool

pub struct DataDownloadProgress {
pub:
	cb     EventDownloadProgress    = unsafe { nil }
	cb_ref EventDownloadProgressRef = unsafe { nil }
pub mut:
	ref   voidptr
	index int
}

fn (mut bwr Browser) build_on_download_progress(mut data DataDownloadProgress) {
	bwr.on('Browser.downloadProgress', fn (mut msg Message, mut data DataDownloadProgress) !bool {
		mut dp := json.decode[DownloadProgress](msg.params.str())!
		dp.index = data.index
		data.index++
		mut is_done := false
		if !isnil(data.cb) {
			is_done = data.cb(mut dp)!
		} else {
			is_done = data.cb_ref(mut dp, data.ref)!
		}
		if dp.state != 'inProgress' && !is_done {
			is_done = true
		}
		return is_done
	}, ref: data)
	bwr.send_event_or_noop('CDV.download')
	bwr.off_all()
}

pub fn (mut bwr Browser) wait_for_download_progress(cb EventDownloadProgress) {
	mut data := &DataDownloadProgress{
		cb: cb
	}
	bwr.build_on_download_progress(mut data)
}

pub fn (mut bwr Browser) wait_for_download_progress_ref(cb EventDownloadProgressRef, ref voidptr) {
	mut data := &DataDownloadProgress{
		cb_ref: cb
		ref:    ref
	}
	bwr.build_on_download_progress(mut data)
}

pub fn (_ DownloadProgress) done() bool {
	return cdv_msg_done
}

pub fn (_ DownloadProgress) next() bool {
	return cdv_msg_next
}
