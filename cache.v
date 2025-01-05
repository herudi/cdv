module cdv

pub fn (mut bwr Browser) clear_cache() {
	bwr.send_or_noop('Network.clearBrowserCache')
}

pub fn (mut page Page) disable_cache() {
	page.send_or_noop('Network.setCacheDisabled',
		params: {
			'cacheDisabled': true
		}
	)
}

pub fn (mut page Page) enable_cache() {
	page.send_or_noop('Network.setCacheDisabled',
		params: {
			'cacheDisabled': false
		}
	)
}
