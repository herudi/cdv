module cdv

import x.json2 as json

@[params]
pub struct EmulationViewportParams {
pub:
	width               int
	height              int
	device_scale_factor f64
	is_mobile           bool
}

pub fn (mut page Page) viewport(params EmulationViewportParams) ! {
	page.send('Emulation.setDeviceMetricsOverride',
		params: {
			'width':             params.width
			'height':            params.height
			'deviceScaleFactor': params.device_scale_factor
			'mobile':            params.is_mobile
		}
	)!
}

pub fn (mut page Page) clear_viewport() ! {
	page.send('Emulation.clearDeviceMetricsOverride')!
}

@[params]
pub struct UserAgentParams {
pub:
	lang     ?string
	platform ?string
	metadata ?map[string]json.Any
}

pub fn (mut page Page) user_agent(name string, params UserAgentParams) ! {
	mut obj := map[string]json.Any{}
	obj['userAgent'] = name
	if lang := params.lang {
		obj['acceptLanguage'] = lang
	}
	if platform := params.platform {
		obj['platform'] = platform
	}
	if metadata := params.metadata {
		obj['userAgentMetadata'] = metadata
	}
	page.send('Emulation.setUserAgentOverride', params: obj)!
}

pub fn (mut page Page) timezone(timezone_id string) ! {
	page.send('Emulation.setTimezoneOverride',
		params: {
			'timezoneId': timezone_id
		}
	)!
}

@[params]
pub struct MediaParams {
pub:
	features ?[]json.Any
}

pub fn (mut page Page) media(media string, params MediaParams) ! {
	mut obj := map[string]json.Any{}
	obj['media'] = media
	if features := params.features {
		obj['features'] = features
	}
	page.send('Emulation.setEmulatedMedia', params: obj)!
}

@[params]
pub struct GeolocationParams {
pub:
	latitude  ?f64
	longitude ?f64
	accuracy  ?f64
}

pub fn (mut page Page) geolocation(params GeolocationParams) ! {
	obj := struct_to_map(params)!
	page.send('Emulation.setEmulatedMedia', params: obj)!
}

pub fn (mut page Page) clear_geolocation() ! {
	page.send('Emulation.clearGeolocationOverride')!
}
