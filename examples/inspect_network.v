import herudi.cdv

fn inspect_network(mut browser cdv.Browser) ! {
	mut tab := browser.new_tab()!

	mut page := tab.use_page()!
	page.navigate(url: 'https://vlang.io/')!
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

fn main() {
	mut browser := cdv.open_chrome()!

	defer { browser.close() }

	inspect_network(mut browser) or {
		browser.close()
		panic(err)
	}
}
