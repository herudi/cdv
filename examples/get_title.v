import cdv

fn main() {
	mut browser := cdv.open_chrome()!

	defer { browser.close() }

	mut page := browser.new_page()

	page.navigate('https://example.com/')
	page.wait_until()

	title := page.eval('document.title').str()

	println(title)

	assert typeof(title).name == 'string'
	assert title.to_lower().contains('example') == true
}
