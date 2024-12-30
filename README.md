# CDV

Headless Browser in V.

> Status: [WIP] Experimental.

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
page.user_agent('my-user-agent')
page.navigate('https://vlang.io')

// code here for listen event fired before wait until page load finished.
page.on('Network.requestWillBeSent', fn (msg cdv.Message, ref voidptr) ! {
	request := msg.params['request']!
	println(request.prettify_json_str())
})

page.wait_until()

// code here for other method.
page.save_as_png('./vlang.png')

```
## Example
this example automate fb login.
```v
mut browser := cdv.open_chrome()!
defer { browser.close() }

mut page := browser.new_page()
page.navigate('https://facebook.com')
page.wait_until()

// selector_all for form
mut forms := page.selectors('form')

// find form by action starts_with `/login`
mut form := forms.find(fn (mut form cdv.Element, i int) !bool {
	return form.attr('action').starts_with('/login')
})?

form.input('#email', 'example@gmail.com')
form.input('#pass', 'my_password')
form.click('button[type="submit"]')

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