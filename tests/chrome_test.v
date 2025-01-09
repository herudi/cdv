import cdv
import time

const browser = cdv.open_chrome(use_pages: true, timeout: 100 * time.second) or { panic(err) }

fn test_browser_version() {
	mut bwr := browser
	version := bwr.get_version()
	is_chrome := version.product.to_lower().contains('chrome')
	assert is_chrome == true
}

fn test_page_eval() {
	mut bwr := browser
	mut page := bwr.new_page()
	page.navigate('https://example.com/')
	page.wait_until()
	title := page.eval('document.title').str()
	assert title.to_lower().contains('example') == true
}

fn test_page_dom() {
	mut bwr := browser
	mut page := bwr.pages[0]
	mut div := page.selector('body > div')
	div.set_attr('foo', 'bar')
	is_foobar := div.str().contains('foo="bar"')
	assert is_foobar == true
}

fn test_page_automate_fb_login() {
	mut bwr := browser
	mut page := bwr.new_page()
	page.navigate('https://facebook.com')
	page.wait_until()

	mut form := page.selector('form')
	mut email := form.selector('#email')
	email.focus()

	mut keyboard := page.use_keyboard()
	keyboard.type('example@gmail.com')
	keyboard.press('Tab')
	keyboard.type('my_password')
	keyboard.press('Enter')

	page.wait_until()
	pathname := page.eval('window.location.pathname').str()
	is_fail := pathname.starts_with('/login')
	assert is_fail == true
}

fn test_page_close() ! {
	mut bwr := browser
	bwr.close()
}
