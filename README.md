# CDV

Chrome Devtools Protocol for `V` and runs in the `Headless` by default.

> This project based on spec https://chromedevtools.github.io/devtools-protocol.

## Install
```bash
v install herudi.cdv
```
## Example
```v
import herudi.cdv

fn inspect_network(mut browser cdv.Browser) ! {
	mut tab := browser.new_tab()!

	mut page := tab.use_page()!

	// goto url
	page.navigate(url: 'https://vlang.io/')!

	// wait until page loaded
	page.load_event_fired(
		cb: fn (res cdv.Result, ref voidptr) ! {
			data := res.as_map()
			method := data['method'] or { '' }.str()
			// see https://chromedevtools.github.io/devtools-protocol/tot/Network/#event-responseReceived
			if method == 'Network.responseReceived' {
				println(data['params']!.prettify_json_str())
				println('\n')
			}
		}
	)!
}

fn save_pdf(mut browser cdv.Browser) ! {
	mut tab := browser.new_tab()!

	mut page := tab.use_page()!

	// goto url
	page.navigate(url: 'https://example.com')!

	// wait until page loaded
	page.load_event_fired()!

	// generate pdf
	res := page.print_to_pdf()!

	// save pdf
	res.save('./example.pdf')!

	println('success save pdf')
}

fn main() {
	mut browser := cdv.open_chrome()!

	defer { browser.close() }

	// tab 1
	inspect_network(mut browser) or {
		browser.close()
		panic(err)
	}

	// tab 2
	save_pdf(mut browser) or {
		browser.close()
		panic(err)
	}
}

```

## License

[MIT](LICENSE)