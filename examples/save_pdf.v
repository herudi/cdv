import herudi.cdv

fn save_pdf(mut browser cdv.Browser) ! {
	mut tab := browser.new_tab()!

	mut page := tab.use_page()!
	page.navigate(url: 'https://example.com')!
	page.load_event_fired()!

	res := page.print_to_pdf()!
	res.save('./example.pdf')!

	println('success save pdf')
}

fn main() {
	mut browser := cdv.open_chrome()!

	defer { browser.close() }

	save_pdf(mut browser) or {
		browser.close()
		panic(err)
	}
}
