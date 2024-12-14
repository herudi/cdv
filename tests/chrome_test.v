import cdv

fn get_title(mut browser cdv.Browser) !string {
	mut tab := browser.new_tab()!

	mut page := tab.use_page()!
	page.navigate(url: 'https://example.com/')!
	page.load_event_fired()!

	mut runtime := tab.use_runtime()!
	res := runtime.evaluate(expression: 'document.title')!.result()
	return res['result']!.as_map()['value']!.str()
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
