module cdv

import x.json2 as json

@[params]
pub struct ScreenshotParams {
pub:
	format                  ?string
	quality                 ?f64
	clip_                   ?json.Any @[json: 'clip']
	from_surface            ?bool     @[json: 'fromSurface']
	capture_beyond_viewport ?bool     @[json: 'captureBeyondViewport']
	optimize_for_speed      ?bool     @[json: 'optimizeForSpeed']
	clip                    ?Viewport @[json: '-']
	path                    ?string   @[json: '-']
}

pub struct Screenshot {
pub:
	data string
}

pub fn (mut page Page) screenshot_opt(opts ScreenshotParams) !Screenshot {
	mut clip := json.Any{}
	mut has_clip := false
	if viewport := opts.clip {
		clip = page.struct_to_json_any(viewport)
		has_clip = true
	}
	mut params := page.struct_to_json_any(opts).as_map()
	if has_clip {
		params['clip_'] = clip
	}
	res := page.send('Page.captureScreenshot', params: params)!.result
	if data := res['data'] {
		data_str := data.str()
		if path := opts.path {
			save_data(path, data_str)!
		}
		return Screenshot{
			data: data_str
		}
	}
	return error('data screenshot not found')
}

pub fn (mut page Page) screenshot(opts ScreenshotParams) Screenshot {
	return page.screenshot_opt(opts) or { page.noop(err) }
}
