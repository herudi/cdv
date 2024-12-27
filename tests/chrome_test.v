import cdv

fn get_title(mut browser cdv.Browser) !string {
	mut page := browser.new_page()!

	page.navigate('https://example.com/')!
	page.wait_until()!

	return page.eval('document.title')!.str()
}

fn test_chrome_browser() ! {
	mut browser := cdv.open_chrome()!

	defer { browser.close() }

	title := get_title(mut browser) or {
		browser.close()
		panic(err)
	}

	assert typeof(title).name == 'string'
	assert title.to_lower().contains('example') == true
}
