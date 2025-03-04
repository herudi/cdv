# CDV

Headless Browser Automation in V.

> Status: Experimental.

> This project based on CDP spec https://chromedevtools.github.io/devtools-protocol.

## Browser Support
- Chrome/Chromium
- Edge
- Firefox
- Safari <i>soon...</i>
- Opera <i>soon...</i>

## Install
```bash
v install --git https://github.com/herudi/cdv
```

## Import
```v
import cdv
```

## Usage
```v
mut browser := cdv.open_chrome()!
defer { browser.close() }

mut page := browser.new_page()

// example config
page.set_viewport(width: 800, height: 400, is_mobile: true)
page.set_user_agent('my-user-agent')

// navigate/goto url
page.navigate('https://news.ycombinator.com/')

// code here for listen event fired before wait until page load finished.

// example listen on_request
page.on_request(fn (mut req cdv.Request) !bool {
	println(req)
	return req.next()
})

// example listen on_response
page.on_response(fn (mut res cdv.Response) !bool {
	println(res)
	return res.next()
})

// wait until load event fired. default to `Page.loadEventFired`.
page.wait_until()
// or use `page.wait_for(2 * time.second)`
// note: timeout in `page.wait_for`, is debouncing from queue of cdp responses.

// code here for other method.

// example generate and save pdf format A4
page.pdf(format: 'A4', path: './news.pdf')

// example generate and save image format png
page.screenshot(format: 'png', path: './news.png')

```
## Example
#### This example automate fb login using DOM Element.
```v
mut browser := cdv.open_chrome()!
defer { browser.close() }

page.navigate('https://facebook.com')
page.wait_until()

mut form := page.selector('form')
mut email := form.selector('#email')
mut pass := form.selector('#pass')
mut submit := form.selector('button[type="submit"]')

email.set_value('example@gmail.com')
pass.set_value('my_password')
submit.click()

page.wait_until()
pathname := page.eval('window.location.pathname').str()
if pathname.starts_with('/login') {
	println('login failed...')
} else {
	println('login success...')
}
```

#### This example automate fb login using Keyboard.
```v
mut browser := cdv.open_chrome()!
defer { browser.close() }

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
if pathname.starts_with('/login') {
	println('login failed...')
} else {
	println('login success...')
}
```

## License

[MIT](LICENSE)