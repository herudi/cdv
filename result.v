module cdv

import x.json2 as json

pub struct Result {
pub:
	id         int = -1
	method     string
	session_id string
pub mut:
	result   map[string]json.Any
	is_error bool
	error    map[string]json.Any
}
