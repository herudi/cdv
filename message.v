module cdv

import x.json2 as json

pub enum MessageType {
	command
	event
}

pub type EventFunc = fn (msg Message, ref voidptr) !

@[params]
pub struct MessageParams {
pub:
	id         int = -1
	method     string
	params     ?map[string]json.Any
	session_id ?string     @[json: 'sessionId']
	typ        MessageType = .command @[json: '-']
}

pub struct Message {
pub:
	method     string
	session_id string
pub mut:
	params map[string]json.Any
}

pub fn (msg Message) has(m string) bool {
	return m != '' && m == msg.method
}
