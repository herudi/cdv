module cdv

import x.json2 as json
import time

pub fn (mut page Page) use_mouse() &Mouse {
	return page.mouse or {
		kb := page.use_keyboard()
		mouse := &Mouse{
			keyboard: kb
			page:     page
		}
		page.mouse = mouse
		return mouse
	}
}

pub enum MouseButton {
	none    = 0
	left    = 1
	right   = 1 << 1
	middle  = 1 << 2
	back    = 1 << 3
	forward = 1 << 4
}

pub fn get_pressed_button(btn int) MouseButton {
	if (btn & int(MouseButton.left)) != 0 {
		return .left
	}
	if (btn & int(MouseButton.right)) != 0 {
		return .right
	}
	if (btn & int(MouseButton.middle)) != 0 {
		return .middle
	}
	if (btn & int(MouseButton.back)) != 0 {
		return .back
	}
	if (btn & int(MouseButton.forward)) != 0 {
		return .forward
	}
	return .none
}

pub struct DataPoint {
pub mut:
	x f64
	y f64
}

pub struct Point {
pub mut:
	x Pos
	y Pos
}

@[heap]
pub struct MouseState {
pub mut:
	position DataPoint
	buttons  int
}

@[heap]
pub struct Mouse {
pub mut:
	state    MouseState
	keyboard &Keyboard
	page     &Page
}

@[params]
pub struct MouseOptions {
pub:
	button      ?MouseButton
	click_count ?int
}

pub fn (mut ms Mouse) down_opt(opts MouseOptions) ! {
	mut button := opts.button or { MouseButton.left }
	mut flag := int(button)
	mut click_count := opts.click_count or { 1 }
	if flag == 0 {
		return error('unsupported button ${button}')
	}
	if (ms.state.buttons & flag) > 0 {
		return error('${button} is already pressed')
	}
	ms.state.buttons = ms.state.buttons | flag
	mut params := map[string]json.Any{}
	params['type'] = 'mousePressed'
	params['modifiers'] = ms.keyboard.modifiers
	params['clickCount'] = click_count
	params['buttons'] = ms.state.buttons
	params['button'] = button.str()
	params['x'] = ms.state.position.x
	params['y'] = ms.state.position.y
	ms.page.send_or_noop('Input.dispatchMouseEvent', params: params)
}

pub fn (mut ms Mouse) down(opts MouseOptions) {
	ms.down_opt(opts) or { ms.page.noop(err) }
}

pub fn (mut ms Mouse) up_opt(opts MouseOptions) ! {
	mut button := opts.button or { MouseButton.left }
	mut flag := int(button)
	mut click_count := opts.click_count or { 1 }
	if flag == 0 {
		return error('unsupported button')
	}
	if (ms.state.buttons & flag) == 0 {
		return error('${button} is already pressed')
	}
	ms.state.buttons = ms.state.buttons & ~flag
	mut params := map[string]json.Any{}
	params['type'] = 'mouseReleased'
	params['modifiers'] = ms.keyboard.modifiers
	params['clickCount'] = click_count
	params['buttons'] = ms.state.buttons
	params['button'] = button.str()
	params['x'] = ms.state.position.x
	params['y'] = ms.state.position.y
	ms.page.send_or_noop('Input.dispatchMouseEvent', params: params)
}

pub fn (mut ms Mouse) up(opts MouseOptions) {
	ms.up_opt(opts) or { ms.page.noop(err) }
}

pub fn (mut ms Mouse) reset() {
	arr := [
		MouseButton.left,
		MouseButton.right,
		MouseButton.middle,
		MouseButton.back,
		MouseButton.forward,
	]
	for btn in arr {
		flag := int(btn)
		if (ms.state.buttons & flag) > 0 {
			ms.up(button: btn)
		}
	}
	if ms.state.position.x != 0 || ms.state.position.y != 0 {
		ms.move(0, 0)
	}
}

@[params]
pub struct MouseClickOptions {
pub:
	button      ?MouseButton
	click_count ?int
	delay       ?i64
	count       ?int
}

pub fn (mut ms Mouse) click_opt(x_pos Pos, y_pos Pos, opts MouseClickOptions) ! {
	x := x_pos.to_f64()
	y := y_pos.to_f64()
	count := opts.count or { 1 }
	click_count := opts.click_count or { 1 }
	if count > 1 {
		return error('Click must occur a positive number of times.')
	}
	if delay := opts.delay {
		time.sleep(delay)
	}
	ms.move(x, y)
	if click_count == count {
		for i := 0; i < count; i++ {
			ms.down(click_count: i, button: opts.button)
			ms.up(click_count: i, button: opts.button)
		}
	}
	ms.down(click_count: click_count, button: opts.button)
	ms.up(click_count: click_count, button: opts.button)
}

pub fn (mut ms Mouse) click(x_pos Pos, y_pos Pos, opts MouseClickOptions) {
	ms.click_opt(x_pos, y_pos, opts) or { ms.page.noop(err) }
}

@[params]
pub struct MouseWheelOptions {
pub:
	delta_x Pos
	delta_y Pos
}

pub fn (mut ms Mouse) wheel(opts MouseWheelOptions) {
	delta_x := opts.delta_x.to_f64()
	delta_y := opts.delta_y.to_f64()
	mut params := map[string]json.Any{}
	params['type'] = 'mouseWheel'
	params['pointerType'] = 'mouse'
	params['modifiers'] = ms.keyboard.modifiers
	params['deltaX'] = delta_x
	params['deltaY'] = delta_y
	params['buttons'] = ms.state.buttons
	params['x'] = ms.state.position.x
	params['y'] = ms.state.position.y
	ms.page.send_or_noop('Input.dispatchMouseEvent', params: params)
}

pub fn (mut ms Mouse) set_intercept_drags(stat bool) {
	ms.page.send_or_noop('Input.setInterceptDrags',
		params: {
			'enabled': stat
		}
	)
}

pub fn (mut ms Mouse) drag(start Point, target Point) {
	ms.move(start.x, start.y)
	ms.down()
	ms.move(target.x, target.y)
}

pub fn (mut ms Mouse) drag_enter(target Point, data json.Any) {
	ms.page.send_or_noop('Input.dispatchDragEvent',
		params: {
			'type':      json.Any('dragEnter')
			'x':         target.x.to_f64()
			'y':         target.y.to_f64()
			'modifiers': ms.keyboard.modifiers
			'data':      data
		}
	)
}

pub fn (mut ms Mouse) drag_over(target Point, data json.Any) {
	ms.page.send_or_noop('Input.dispatchDragEvent',
		params: {
			'type':      json.Any('dragOver')
			'x':         target.x.to_f64()
			'y':         target.y.to_f64()
			'modifiers': ms.keyboard.modifiers
			'data':      data
		}
	)
}

pub fn (mut ms Mouse) drop(target Point, data json.Any) {
	ms.page.send_or_noop('Input.dispatchDragEvent',
		params: {
			'type':      json.Any('drop')
			'x':         target.x.to_f64()
			'y':         target.y.to_f64()
			'modifiers': ms.keyboard.modifiers
			'data':      data
		}
	)
}

@[params]
pub struct DragOptions {
pub:
	delay ?i64
}

struct DragData {
mut:
	drag_data ?json.Any
}

pub fn (mut ms Mouse) drag_and_drop(start Point, target Point, opts DragOptions) {
	ms.drag(start, target)
	mut data := &DragData{}
	ms.wait_for_drag(fn (mut msg Message, mut data DragData) !bool {
		if drag_data := msg.params['data'] {
			data.drag_data = drag_data
		}
		return msg.done()
	}, ref: data)
	if drag_data := data.drag_data {
		ms.drag_enter(target, drag_data)
		ms.drag_over(target, drag_data)
		if delay := opts.delay {
			time.sleep(delay)
		}
		ms.drop(target, drag_data)
	}
	ms.up()
}

pub fn (mut ms Mouse) wait_for_drag(cb EventFunc, params ParamRefTimeout) {
	ms.page.on('Input.dragIntercepted', cb, ref: params.ref)
	ms.page.wait_for(params.timeout)
}

@[params]
pub struct MouseMoveOptions {
pub:
	steps ?int
}

pub type Pos = int | f64

pub fn (p Pos) to_f64() f64 {
	return match p {
		int { f64(p) }
		else { p as f64 }
	}
}

pub fn (mut ms Mouse) move_opt(pos_x Pos, pos_y Pos, opts MouseMoveOptions) ! {
	mut steps := opts.steps or { 1 }
	mut from := ms.state.position
	mut x := pos_x.to_f64()
	mut y := pos_y.to_f64()
	mut to := DataPoint{x, y}
	for i := 1; i <= steps; i++ {
		ms.state.position = DataPoint{
			x: from.x + (to.x - from.x) * (i / steps)
			y: from.y + (to.y - from.y) * (i / steps)
		}
		mut params := map[string]json.Any{}
		params['type'] = 'mouseMoved'
		params['modifiers'] = ms.keyboard.modifiers
		params['buttons'] = ms.state.buttons
		params['button'] = get_pressed_button(ms.state.buttons).str()
		params['x'] = ms.state.position.x
		params['y'] = ms.state.position.y
		ms.page.send_or_noop('Input.dispatchMouseEvent', params: params)
	}
}

pub fn (mut ms Mouse) move(x Pos, y Pos, opts MouseMoveOptions) {
	ms.move_opt(x, y, opts) or { ms.page.noop(err) }
}
