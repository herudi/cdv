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
	name                       string
	sysex                      ?bool
	user_visible_only          ?bool   @[json: 'userVisibleOnly']
	allow_without_sanitization ?bool   @[json: 'allowWithoutSanitization']
	allow_without_gesture      ?bool   @[json: 'allowWithoutGesture']
	pan_tilt_zoom              ?bool   @[json: 'panTiltZoom']
	origin                     ?string @[json: '-']
}

pub fn (mut bwr Browser) set_permission(name string, setting PermissionSetting, opts SetPermissionParams) {
	mut params := map[string]json.Any{}
	params['permission'] = bwr.struct_to_json_any(SetPermissionParams{ ...opts, name: name })
	params['setting'] = setting.str()
	if origin := opts.origin {
		params['origin'] = origin
	}
	if ctx_id := bwr.browser_context_id {
		params['browserContextId'] = ctx_id
	}
	bwr.send_or_noop('Browser.setPermission', params: params)
}

pub fn (mut bwr Browser) reset_permissions() {
	mut params := map[string]json.Any{}
	if ctx_id := bwr.browser_context_id {
		params['browserContextId'] = ctx_id
	}
	bwr.send_or_noop('Browser.resetPermissions', params: params)
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
	bwr.send_or_noop('Browser.grantPermissions', params: params)
}
