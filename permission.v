module cdv

import x.json2 as json

pub enum PermissionSetting {
	granted
	denied
	prompt
}

@[params]
pub struct SetPermissionParams {
pub:
	origin ?string
}

pub fn (mut bwr Browser) set_permission(permission map[string]json.Any, setting PermissionSetting, opts SetPermissionParams) {
	mut params := map[string]json.Any{}
	params['permission'] = json.Any(permission)
	params['setting'] = setting.str()
	if origin := opts.origin {
		params['origin'] = origin
	}
	if ctx_id := bwr.browser_context_id {
		params['browserContextId'] = ctx_id
	}
	bwr.send_panic('Browser.setPermission', params: params)
}

pub fn (mut bwr Browser) reset_permissions() {
	mut params := map[string]json.Any{}
	if ctx_id := bwr.browser_context_id {
		params['browserContextId'] = ctx_id
	}
	bwr.send_panic('Browser.resetPermissions', params: params)
}

@[params]
pub struct GrandPermissionParams {
pub:
	origin ?string
}

pub fn (mut bwr Browser) grand_permissions(permission_name string, opts GrandPermissionParams) {
	mut params := map[string]json.Any{}
	params['permissions'] = permission_name
	if origin := opts.origin {
		params['origin'] = origin
	}
	if ctx_id := bwr.browser_context_id {
		params['browserContextId'] = ctx_id
	}
	bwr.send_panic('Browser.grantPermissions', params: params)
}
