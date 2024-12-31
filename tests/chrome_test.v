import cdv

struct MyApp {
mut:
	browser &cdv.Browser
	pages   []cdv.Page
}

fn new_app(opts cdv.Config) &MyApp {
	browser := cdv.open_chrome(opts) or { panic(err) }
	return &MyApp{
		browser: browser
	}
}

fn (mut app MyApp) close() {
	app.browser.close()
}

const c_app = new_app()

fn test_browser_version() {
	mut app := c_app
	version := app.browser.version()
	is_chrome := version.product.to_lower().contains('chrome')
	assert is_chrome == true
}

fn test_page_eval() {
	mut app := c_app
	mut page := app.browser.new_page()
	page.navigate('https://example.com/')
	page.wait_until()
	title := page.eval('document.title').str()
	assert title.to_lower().contains('example') == true
	app.pages << page
}

fn test_page_dom() {
	mut app := c_app
	mut page := app.pages[0]
	mut div := page.selector('body > div')
	div.attr('foo', 'bar')
	is_foobar := div.outer_html().contains('foo="bar"')
	assert is_foobar == true
}

fn test_page_automate_fb_login() {
	mut app := c_app
	mut page := app.browser.new_page()
	page.navigate('https://facebook.com')
	page.wait_until()
	mut form := page.selector('form')
	form.input('#email', 'example@gmail.com')
	form.input('#pass', 'my_password')
	form.click('button[type="submit"]')
	page.wait_until()
	pathname := page.eval('window.location.pathname').str()
	is_fail := pathname.starts_with('/login')
	assert is_fail == true
}

fn test_page_close() ! {
	mut app := c_app
	app.close()
}
