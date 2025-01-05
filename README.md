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
page.on_request(fn (mut req cdv.Request) ! {
	println(req)
})

// example listen on_response
page.on_response(fn (mut res cdv.Response) ! {
	println(res)
})

// wait until load event fired. default to `Page.loadEventFired`.
page.wait_until()

// code here for other method.

// example generate and save pdf format A4
page.pdf(format: 'A4', path: './news.pdf')

// example generate and save image format png
page.screenshot(format: 'png', path: './news.png')

```
## Example
this example automate fb login.
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

## License

[MIT](LICENSE)