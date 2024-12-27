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
}

pub struct Screenshot {
pub:
	data string
}

pub fn (mut page Page) screenshot(opts ScreenshotParams) !Screenshot {
	mut clip := map[string]json.Any{}
	mut has_clip := false
	if viewport := opts.clip {
		clip = struct_to_map(viewport)!
		has_clip = true
	}
	params := struct_to_map(ScreenshotParams{
		...opts
		clip_: if has_clip { json.Any(clip) } else { none }
	})!
	res := page.send('Page.captureScreenshot', params: params)!.result
	if data := res['data'] {
		return Screenshot{
			data: data.str()
		}
	}
	return error('data not found')
}

pub fn (mut page Page) save_as_png(path string, opts ScreenshotParams) ! {
	data := page.screenshot(ScreenshotParams{ ...opts, format: 'png' })!
	data.save(path)!
}

pub fn (mut page Page) save_as_jpeg(path string, opts ScreenshotParams) ! {
	data := page.screenshot(ScreenshotParams{ ...opts, format: 'jpeg' })!
	data.save(path)!
}

pub fn (mut page Page) save_as_webp(path string, opts ScreenshotParams) ! {
	data := page.screenshot(ScreenshotParams{ ...opts, format: 'webp' })!
	data.save(path)!
}

pub fn (sc Screenshot) save(path string) ! {
	save_data(path, sc.data)!
}
