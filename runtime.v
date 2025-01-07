module cdv

import x.json2 as json

pub struct RuntimeRemoteObject {
pub:
	typ                   string @[json: 'type']
	value                 ?json.Any
	subtype               ?string
	class_name            ?string   @[json: 'className']
	unserializable_value  ?string   @[json: 'unserializableValue']
	object_id             ?string   @[json: 'objectId']
	deep_serialized_value ?json.Any @[json: 'deepSerializedValue']
	custom_preview        ?json.Any @[json: 'customPreview']
	preview               ?json.Any
	description           ?string
}

@[params]
pub struct RuntimeEvaluateParams {
pub:
	expression                       string               @[json: 'expression']
	object_group                     ?string              @[json: 'objectGroup']
	include_command_line_api         ?bool                @[json: 'includeCommandLineAPI']
	silent                           ?bool                @[json: 'silent']
	context_id                       ?int                 @[json: 'contextId']
	return_by_value                  ?bool                @[json: 'returnByValue']
	generate_preview                 ?bool                @[json: 'generatePreview']
	user_gesture                     ?bool                @[json: 'userGesture']
	await_promise                    ?bool                @[json: 'awaitPromise']
	throw_on_side_effect             ?bool                @[json: 'throwOnSideEffect']
	timeout                          ?f64                 @[json: 'timeout']
	disable_breaks                   ?bool                @[json: 'disableBreaks']
	repl_mode                        ?bool                @[json: 'replMode']
	allow_unsafe_eval_blocked_by_csp ?bool                @[json: 'allowUnsafeEvalBlockedByCSP']
	unique_context_id                ?string              @[json: 'uniqueContextId']
	serialization_options            ?map[string]json.Any @[json: 'serializationOptions']
}

pub fn (mut page Page) eval_fn(js_fn string, opts RuntimeEvaluateParams) json.Any {
	mut await_promise := opts.await_promise or { false }
	if !await_promise && js_fn.starts_with('async') {
		await_promise = true
	}
	exp := '(${js_fn})()'
	return page.eval(exp, RuntimeEvaluateParams{ ...opts, await_promise: await_promise })
}

pub fn (mut page Page) eval(exp string, opts RuntimeEvaluateParams) json.Any {
	res := page.eval_opt(exp, RuntimeEvaluateParams{ ...opts, return_by_value: true }) or {
		page.noop(err)
	}
	return res.value or { json.Any{} }
}

pub fn (mut page Page) eval_all(exp string, opts RuntimeEvaluateParams) RuntimeRemoteObject {
	return page.eval_opt(exp, opts) or { page.noop(err) }
}

pub fn (mut page Page) eval_opt(exp string, opts RuntimeEvaluateParams) !RuntimeRemoteObject {
	params := struct_to_json_any(RuntimeEvaluateParams{
		...opts
		expression: exp
	})!.as_map()
	result := page.send('Runtime.evaluate', params: params)!.result
	if js_error := result['exceptionDetails'] {
		return error(js_error.prettify_json_str())
	}
	if data := result['result'] {
		return json.decode[RuntimeRemoteObject](data.str())!
	}
	return error('cannot find result')
}
