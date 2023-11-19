class_name __GDRx_Engine__
## Provides access to Godot-specific [Observable] constructors.
##
## Bridge between Godot-specific implementations and [__GDRx_Singleton__]

# =========================================================================== #
#   Observables
# =========================================================================== #
var _GodotSignal_ = load("res://addons/reactivex/engine/observable/godotsignal.gd")
var _GodotLifecycle_ = load("res://addons/reactivex/engine/observable/godotnodelifecycle.gd")
var _GodotInputAction_ = load("res://addons/reactivex/engine/observable/godotinputaction.gd")
var _GodotCoroutine_ = load("res://addons/reactivex/engine/observable/godotcoroutine.gd")
var _ComputeShader_ = load("res://addons/reactivex/engine/observable/computeshader.gd")
var _HttpRequest_ = load("res://addons/reactivex/engine/observable/httprequest.gd")

var _ProcessTimeInterval_ = load("res://addons/reactivex/engine/operators/_processtimeinterval.gd")

## See: [b]res://addons/reactivex/engine/observable/godotsignal.gd[/b]
func from_godot_signal(sig : Signal, scheduler : SchedulerBase = null) -> Observable:
	return _GodotSignal_.from_godot_signal_(sig, scheduler)

## See: [b]res://addons/reactivex/engine/observable/godotnodelifecycle.gd[/b]
func from_godot_node_lifecycle_event(conn : Node, type : int) -> Observable:
	return _GodotLifecycle_.from_godot_node_lifecycle_event_(conn, type)

## See: [b]res://addons/reactivex/engine/observable/godotinputaction.gd[/b]
func from_godot_input_action(input_action : String, checks : Observable) -> Observable:
	return _GodotInputAction_.from_godot_input_action_(input_action, checks)

## See: [b]res://addons/reactivex/engine/observable/godotcoroutine.gd[/b]
func from_godot_coroutine(fun : Callable, bindings : Array = [], scheduler : SchedulerBase = null) -> Observable:
	return _GodotCoroutine_.from_godot_coroutine_(fun, bindings, scheduler)

## See: [b]"res://addons/reactivex/engine/observable/computeshader.gd"[/b]
func from_compute_shader(shader_path : String, rd : RenderingDevice, work_groups : Vector3i, uniform_sets : Array = [], scheduler : SchedulerBase = null) -> Observable:
	return _ComputeShader_.from_compute_shader_(shader_path, rd, work_groups, uniform_sets, scheduler)

## See: [b]"res://addons/reactivex/engine/observable/httprequest.gd"[/b]
func from_http_request(url : String, request_data = "", raw : bool = false, encoding : String = "", requester : HTTPRequest = null, custom_headers : PackedStringArray = PackedStringArray(), method : HTTPClient.Method = HTTPClient.METHOD_GET) -> Observable:
	return _HttpRequest_.from_http_request_(url, request_data, raw, encoding, requester, custom_headers, method)

## See: [b]"res://addons/reactivex/engine/operators/_processtimeinterval.gd"[/b]
func process_time_interval(initial_time : float = 0.0) -> Callable:
	return _ProcessTimeInterval_.process_time_interval_(initial_time)

## See: [b]"res://addons/reactivex/engine/operators/_processtimeinterval.gd"[/b]
func physics_time_interval(initial_time : float = 0.0) -> Callable:
	return _ProcessTimeInterval_.physics_time_interval_(initial_time)
