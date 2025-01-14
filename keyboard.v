module cdv

import x.json2 as json
import time

pub struct Keyboard {
pub mut:
	modifiers    int
	pressed_keys []string
	page         &Page
}

pub fn (mut page Page) use_keyboard() &Keyboard {
	return page.keyboard or {
		kb := &Keyboard{
			page: page
		}
		page.keyboard = kb
		return kb
	}
}

@[params]
pub struct KeyEventParams {
pub:
	typ                      string @[json: 'type']
	modifiers                ?int
	timestamp                ?f64
	text                     ?string
	unmodified_text          ?string @[json: 'unmodifiedText']
	key_identifier           ?string @[json: 'keyIdentifier']
	code                     ?string @[json: 'code']
	key                      ?string @[json: 'key']
	windows_virtual_key_code ?int    @[json: 'windowsVirtualKeyCode']
	native_virtual_key_code  ?int    @[json: 'nativeVirtualKeyCode']
	auto_repeat              ?bool   @[json: 'autoRepeat']
	is_keypad                ?bool   @[json: 'isKeypad']
	is_system_key            ?bool   @[json: 'isSystemKey']
	location                 ?int
	commands                 ?[]string
}

pub fn (mut kb Keyboard) dispatch_key_event(opts KeyEventParams) ! {
	params := struct_to_json_any(opts)!.as_map()
	kb.page.send_or_noop('Input.dispatchKeyEvent', params: params)
}

fn (mut kb Keyboard) get_modifiers(key string) int {
	return match key {
		'Alt' { 1 }
		'Control' { 2 }
		'Meta' { 4 }
		'Shift' { 8 }
		else { 0 }
	}
}

@[params]
pub struct OptionsDown {
pub:
	text     ?string
	commands []string
	delay    ?i64
}

pub fn (mut kb Keyboard) down(key string, opts OptionsDown) {
	mut params := map[string]json.Any{}
	mut desc := kb.get_desc(key)
	kb.modifiers |= kb.get_modifiers(desc.key)
	mut text := opts.text or { desc.text }
	auto_repeat := kb.pressed_keys.contains(desc.code)
	if !auto_repeat {
		kb.pressed_keys << desc.code
	}
	params['commands'] = opts.commands.map(json.Any(it))
	params['text'] = text
	params['type'] = if text != '' { 'keyDown' } else { 'rawKeyDown' }
	params['modifiers'] = kb.modifiers
	params['key'] = desc.key
	params['windowsVirtualKeyCode'] = desc.key_code
	params['code'] = desc.code
	params['unmodifiedText'] = text
	params['autoRepeat'] = auto_repeat
	params['location'] = desc.location
	params['isKeypad'] = desc.location == 3
	kb.page.send_or_noop('Input.dispatchKeyEvent', params: params)
}

pub fn (mut kb Keyboard) up(key string) {
	mut params := map[string]json.Any{}
	mut desc := kb.get_desc(key)
	kb.modifiers &= ~kb.get_modifiers(desc.key)
	idx := kb.pressed_keys.index(desc.code)
	kb.pressed_keys.delete(idx)
	params['type'] = 'keyUp'
	params['modifiers'] = kb.modifiers
	params['key'] = desc.key
	params['windowsVirtualKeyCode'] = desc.key_code
	params['code'] = desc.code
	params['location'] = desc.location
	kb.page.send_or_noop('Input.dispatchKeyEvent', params: params)
}

pub fn (mut kb Keyboard) press(key string, opts OptionsDown) {
	kb.down(key, opts)
	if delay := opts.delay {
		time.sleep(delay)
	}
	kb.up(key)
}

pub fn (mut kb Keyboard) send_character(text string) {
	kb.page.send_or_noop('Input.insertText',
		params: {
			'text': text
		}
	)
}

pub fn (mut kb Keyboard) type(text string, opts OptionsDown) {
	for rn in text.runes() {
		chr := rn.str()
		if chr in key_map {
			kb.press(chr, delay: opts.delay)
		} else {
			if delay := opts.delay {
				time.sleep(delay)
			}
			kb.send_character(chr)
		}
	}
}

struct KeyDesc {
mut:
	key      string
	key_code int
	code     string
	text     string
	location int
}

fn (mut kb Keyboard) get_desc(key string) KeyDesc {
	if key !in key_map {
		eprintln('unknown key ${key}')
		return KeyDesc{}
	}
	is_shift := (kb.modifiers & 8) != 0
	mut def := key_map[key].clone()
	mut desc := KeyDesc{}
	if d_key := def['key'] {
		desc.key = d_key.str()
	}
	if is_shift && def['shiftKey'] or { '' }.str() != '' {
		desc.key = def['shiftKey'] or { '' }.str()
	}
	if key_code := def['keyCode'] {
		desc.key_code = key_code.int()
	}
	if is_shift && def['shiftKeyCode'] or { json.Any(-1) }.int() != -1 {
		desc.key_code = def['shiftKeyCode'] or { json.Any(0) }.int()
	}
	if code := def['code'] {
		desc.code = code.str()
	}
	if location := def['location'] {
		desc.location = location.int()
	}
	if desc.key.len == 1 {
		desc.text = desc.key
	}

	if text := def['text'] {
		desc.text = text.str()
	}

	if is_shift && def['shiftText'] or { '' }.str() != '' {
		desc.text = def['shiftText'] or { '' }.str()
	}
	if (kb.modifiers & ~8) > 0 {
		desc.text = ''
	}
	return desc
}
