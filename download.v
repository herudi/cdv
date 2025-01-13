module cdv

import x.json2 as json
import os

@[params]
pub struct DownloadBehaviorParams {
pub:
	behavior           string
	browser_context_id ?string @[json: 'browserContextId']
	download_path      ?string @[json: 'downloadPath']
	event              ?bool   @[json: 'eventsEnabled']
}

pub fn (mut bwr Browser) set_download_behavior_opt(behavior string, opts DownloadBehaviorParams) ! {
	mut params := bwr.struct_to_json_any(DownloadBehaviorParams{
		...opts
		behavior:           behavior
		browser_context_id: bwr.browser_context_id
	}).as_map()
	if dl_path := params['downloadPath'] {
		mut path := dl_path.str()
		if !os.exists(path) {
			return error('${path} does not exists')
		}
		if !os.is_abs_path(path) {
			path = os.abs_path(path)
			params['downloadPath'] = json.Any(path)
		}
	}
	bwr.send_or_noop('Browser.setDownloadBehavior', params: params)
}

pub fn (mut bwr Browser) set_download_behavior(behavior string, opts DownloadBehaviorParams) {
	bwr.set_download_behavior_opt(behavior, opts) or { bwr.noop(err) }
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

fn (mut bwr Browser) build_on_download_progress(mut data DataDownloadProgress, opts ParamTimeout) {
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
	bwr.send_event_or_noop('CDV.waitFor', timeout: opts.timeout)
	bwr.off_all()
}

pub fn (mut bwr Browser) wait_for_download_progress(cb EventDownloadProgress, opts ParamTimeout) {
	mut data := &DataDownloadProgress{
		cb: cb
	}
	bwr.build_on_download_progress(mut data, opts)
}

pub fn (mut bwr Browser) wait_for_download_progress_ref(cb EventDownloadProgressRef, ref voidptr, opts ParamTimeout) {
	mut data := &DataDownloadProgress{
		cb_ref: cb
		ref:    ref
	}
	bwr.build_on_download_progress(mut data, opts)
}

pub fn (_ DownloadProgress) done() bool {
	return cdv_msg_done
}

pub fn (_ DownloadProgress) next() bool {
	return cdv_msg_next
}

pub fn (mut page Page) set_download_behavior(behavior string, opts DownloadBehaviorParams) {
	page.browser.set_download_behavior(behavior, opts)
}

pub fn (mut page Page) cancel_download(guid string) {
	page.browser.cancel_download(guid)
}

pub fn (mut page Page) wait_for_download_progress(cb EventDownloadProgress, opts ParamTimeout) {
	page.browser.wait_for_download_progress(cb, opts)
}

pub fn (mut page Page) wait_for_download_progress_ref(cb EventDownloadProgressRef, ref voidptr, opts ParamTimeout) {
	page.browser.wait_for_download_progress_ref(cb, ref, opts)
}
