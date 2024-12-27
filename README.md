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

mut page := browser.new_page()!
page.navigate('https://vlang.io')!

// code here for listen event fired before page loaded.
page.on('Network.requestWillBeSent', fn (msg cdv.Message, ref voidptr) ! {
	request := msg.params['request']!
	println(request.prettify_json_str())
})

page.wait_until()!

// code here for other method.
img := page.screenshot(format: 'png')!

img.save('./vlang.png')!

```
## Example
this example automate fb login.
```v
mut browser := cdv.open_chrome()!
defer { browser.close() }

mut page := browser.new_page()!
page.navigate('https://facebook.com')!
page.wait_until()!

mut form := page.selector('form[action="/login"]')!

mut email := form.selector('#email')!
email.set_value('example@gmail.com')!
email_str := email.get_value()!

mut passwd := form.selector('#pass')!
passwd.set_value('myscreetpass')!

mut btn := form.selector('button[type="submit"]')!
btn.click()!

page.wait_until()!

pathname := page.eval('window.location.pathname')!.str()
if pathname.starts_with('/login') {
	println('login failed for email "${email_str}"')
} else {
	println('login success...')
}
```

## Recipt
For better error handling and close browser.
```v
import cdv

fn get_title(mut browser cdv.Browser) !string {
	mut page := browser.new_page()!

	page.navigate('https://example.com/')!
	page.wait_until()!

	return page.eval('document.title')!.str()
}

fn main() {
	mut browser := cdv.open_chrome()!

	defer { browser.close() }

	title := get_title(mut browser) or {
		browser.close()
		panic(err)
	}

	println(title)
}
```

## License

[MIT](LICENSE)