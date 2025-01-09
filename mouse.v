module cdv

import x.json2 as json

@[params]
pub struct MouseParams {
pub:
	keyboard ?&Keyboard
}

pub fn (mut page Page) use_mouse(opts MouseParams) &Mouse {
	mut keyboard := unsafe { nil }
	if kb := opts.keyboard {
		keyboard = kb
	} else {
		keyboard = page.use_keyboard()
	}
	return &Mouse{
		keyboard: keyboard
		page:     page
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

pub struct Point {
pub mut:
	x f64
	y f64
}

@[heap]
pub struct MouseState {
pub mut:
	position Point
	buttons  int
}

fn (mut state MouseState) assign(args ...MouseState) MouseState {
	for arg in args {
		state.position = arg.position
		state.buttons = arg.buttons
	}
	return state
}

@[heap]
pub struct Mouse {
pub mut:
	state        MouseState
	keyboard     &Keyboard
	page         &Page
	transactions []MouseState
}

fn (mut ms Mouse) get_state() MouseState {
	return ms.state.assign(...ms.transactions)
}

pub struct MouseTransaction {
pub mut:
	mouse       &Mouse
	transaction MouseState
}

fn (mut trx MouseTransaction) update(mut updated MouseState) {
	trx.transaction.assign(updated)
}

fn (mut trx MouseTransaction) commit() {
	trx.mouse.state.assign(trx.transaction)
	trx.rollback()
}

fn (mut trx MouseTransaction) rollback() {
	idx := trx.mouse.transactions.index(trx.transaction)
	if idx != -1 {
		trx.mouse.transactions.delete(idx)
	}
}

fn (mut ms Mouse) create_trx() MouseTransaction {
	mut transaction := MouseState{}
	ms.transactions << transaction
	return MouseTransaction{
		mouse:       ms
		transaction: transaction
	}
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
	mut trx := ms.create_trx()
	trx.update(mut MouseState{
		buttons: ms.state.buttons | flag
	})
	mut params := map[string]json.Any{}
	params['type'] = 'mousePressed'
	params['modifiers'] = ms.keyboard.modifiers
	params['clickCount'] = click_count
	params['buttons'] = ms.state.buttons
	params['button'] = button.str()
	params['x'] = ms.state.position.x
	params['y'] = ms.state.position.y
	ms.page.send_or_noop('Input.dispatchMouseEvent', params: params)
	trx.commit()
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
	if (ms.state.buttons & flag) > 0 {
		return error('${button} is already pressed')
	}
	mut trx := ms.create_trx()
	trx.update(mut MouseState{
		buttons: ms.state.buttons & ~flag
	})
	mut params := map[string]json.Any{}
	params['type'] = 'mouseReleased'
	params['modifiers'] = ms.keyboard.modifiers
	params['clickCount'] = click_count
	params['buttons'] = ms.state.buttons
	params['button'] = button.str()
	params['x'] = ms.state.position.x
	params['y'] = ms.state.position.y
	ms.page.send_or_noop('Input.dispatchMouseEvent', params: params)
	trx.commit()
}

pub fn (mut ms Mouse) up(opts MouseOptions) {
	ms.up_opt(opts) or { ms.page.noop(err) }
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
	mut to := Point{x, y}
	for i := 1; i <= steps; i++ {
		mut trx := ms.create_trx()
		trx.update(mut MouseState{
			position: Point{
				x: from.x + (to.x - from.x) * (i / steps)
				y: from.y + (to.y - from.y) * (i / steps)
			}
		})
		mut params := map[string]json.Any{}
		params['type'] = 'mouseMoved'
		params['modifiers'] = ms.keyboard.modifiers
		params['buttons'] = ms.state.buttons
		params['button'] = get_pressed_button(ms.state.buttons).str()
		params['x'] = ms.state.position.x
		params['y'] = ms.state.position.y
		ms.page.send_or_noop('Input.dispatchMouseEvent', params: params)
		trx.commit()
	}
}

pub fn (mut ms Mouse) move(x Pos, y Pos, opts MouseMoveOptions) {
	ms.move_opt(x, y, opts) or { ms.page.noop(err) }
}
