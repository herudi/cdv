module cdv

import x.json2 as json

@[heap]
pub struct Tab {
pub mut:
	next_id    int = 1
	target_id  string
	browser    &Browser = unsafe { nil }
	session_id string
	deps       []string
}

pub fn (mut bwr Browser) new_tab() !&Tab {
	has_init := bwr.tab_map.len == 0
	mut target_id := ''
	if has_init {
		target_id = bwr.target_id
	} else {
		new_target := bwr.send('Target.createTarget',
			params: {
				'url': 'about:blank'
			}
		)!.as_map()['result']!.as_map()
		target_id = new_target['targetId']!.str()
	}
	attach := bwr.send('Target.attachToTarget',
		params: {
			'targetId': json.Any(target_id)
			'flatten':  true
		}
	)!.as_map()['result']!.as_map()
	session_id := attach['sessionId']!.str()
	mut tab := &Tab{
		target_id:  target_id
		browser:    bwr
		session_id: session_id
	}
	bwr.tab_map[target_id] = TabMap{
		session_id: session_id
	}
	return tab
}

pub fn (mut tab Tab) send(method string, msg Message) !Result {
	id := tab.get_next_id(msg.id)
	target_id := tab.target_id
	if target_id in tab.browser.tab_map {
		tab.browser.tab_map[target_id].next_id = tab.next_id
	}
	return tab.browser.send(method, Message{ ...msg, id: id, session_id: tab.session_id })!
}

pub fn (mut tab Tab) on(method string, msg Message) !Result {
	id := tab.get_next_id(msg.id)
	target_id := tab.target_id
	if target_id in tab.browser.tab_map {
		tab.browser.tab_map[target_id].next_id = tab.next_id
	}
	return tab.browser.on(method, Message{ ...msg, id: id, session_id: tab.session_id })!
}

@[params]
pub struct CloseTargetConfig {
pub:
	force_close_browser bool
}

pub fn (mut tab Tab) close(opts CloseTargetConfig) {
	if opts.force_close_browser || tab.target_id != tab.browser.target_id {
		tab.close_target()
		return
	}
	tab.send('Page.navigate',
		params: {
			'url': 'about:blank'
		}
	) or {}
}

fn (mut tab Tab) close_target() {
	tab.send('Target.closeTarget',
		params: {
			'targetId': tab.target_id
		}
	) or {
		eprintln('tab is closed')
		return
	}
	target_id := tab.target_id
	tab.browser.tab_map.delete(target_id)
}

fn (mut tab Tab) get_next_id(current_id int) int {
	mut id := current_id
	if id == -1 {
		id = tab.next_id++
	}
	return id
}
