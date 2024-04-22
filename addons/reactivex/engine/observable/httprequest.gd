## Struct representing the results of a [HTTPRequest]
class HttpRequestResult:
	var result : int
	var response_code : int
	var headers : PackedStringArray
	var body : PackedByteArray
	var decoded : String = ""

## Performs an [HTTPRequest] on subscribe
static func from_http_request_(
	url : String,
	request_data = "", 
	raw : bool = false,
	encoding : String = "",
	requester : HTTPRequest = null,
	custom_headers : PackedStringArray = PackedStringArray(),
#	tls_validate_domain : bool = true,
	method : HTTPClient.Method = HTTPClient.METHOD_GET
) -> Observable:
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		
		var gss : GodotSignalScheduler
		if scheduler != null and scheduler is GodotSignalScheduler:
			gss = scheduler as GodotSignalScheduler
		else: gss = GodotSignalScheduler.singleton()
		
		var _requester : HTTPRequest = requester if requester != null else HTTPRequest.new()
		if requester == null: GDRx.add_child(_requester)
		var n_bytes = _requester.get_downloaded_bytes()
		
		var action = func(result : int, response_code : int, headers : PackedStringArray, body : PackedByteArray):
			if requester == null: _requester.queue_free()
			if _requester.get_downloaded_bytes() - n_bytes == 0:
				observer.on_error(HttpRequestFailedError.new(url, 0, "No data received"))
				return
			var http_request_result : HttpRequestResult = HttpRequestResult.new()
			http_request_result.result = result
			http_request_result.response_code = response_code
			http_request_result.headers = headers
			http_request_result.body = body
			if not encoding.is_empty():
				var encodings = {
					"ascii" : func(): return body.get_string_from_ascii(),
					"utf8" : func(): return body.get_string_from_utf8(),
					"utf16" : func(): return body.get_string_from_utf16(),
					"utf32" : func(): return body.get_string_from_utf32()
				}
				if not encoding in encodings:
					observer.on_error(BadArgumentError.new("Unknown encoding: " + str(encoding)))
					return
				var get_string : Callable = encodings[encoding]
				http_request_result.decoded = get_string.call()
			observer.on_next(http_request_result)
			observer.on_completed()
		
		var dispose = func():
			if requester == null:
				_requester.cancel_request()
				_requester.queue_free()
		
		var request_cb : Callable = _requester.request_raw if raw else _requester.request
		var error_code = request_cb.call(url, custom_headers, method, request_data)
		if error_code:
			dispose.call()
			observer.on_error(HttpRequestFailedError.new(
				url, error_code, "Unable to create request"))
			return Disposable.new()
		
		var subscription = gss.schedule_signal(_requester.request_completed, 4, action)
		var cd = CompositeDisposable.new([Disposable.new(dispose), subscription])
		return cd
	
	return Observable.new(subscribe)
