extends Node
class_name __GDRx_Singleton__

## GDRx Singleton Script
##
## Provides access to [Observable] constructors and operators.
## [color=yellow] Please add to autoload with name [code]GDRx[/code]![/color]

# =========================================================================== #
#   Init script database
# =========================================================================== #
## Access to internals
var __init__ : __GDRx_Init__ = __GDRx_Init__.new()
## [Observable] constructor functions
var obs : __GDRx_Obs__ = __GDRx_Obs__.new()
## [Observable] operator functions
var op : __GDRx_Op__ = __GDRx_Op__.new()
## Engine Backend
var gd : __GDRx_Engine__ = __GDRx_Engine__.new()
## See [OnNextNotification]
var OnNext = __init__.NotificationOnNext_
## See [OnErrorNotification]
var OnError = __init__.NotificationOnError_
## See [OnCompletedNotification]
var OnCompleted = __init__.NotificationOnCompleted_

## Internal heap implementation
var heap = __init__.Heap_.new()
## Basic functions & types
var basic = __init__.Basic_.new()
## Concurrency functions & types
var concur = __init__.Concurrency_.new()
## Utility functions & types
var util = __init__.Util_.new()
## Exception types
var exc = __init__.Exception_.new()
## Access to pipe operators
var pipe = __init__.Pipe_.new()

# =========================================================================== #
#   Multi-Threading
# =========================================================================== #

## Dummy instance for the Main Thread
var MAIN_THREAD = _MainThreadDummy.new()
## ID of the main thread
var MAIN_THREAD_ID = OS.get_thread_caller_id()
## Interval in which GDRx checks whether registered threads are finished and
## can be joined.
const THREAD_JOIN_INTERVAL : float = 1.0

## Dummy class to represent the main [Thread] instance
class _MainThreadDummy extends Thread:
	func start(_callable : Callable, _priority : int = 1) -> int:
		GDRx.raise_message("Do not launch the Main Thread Dummy!")
		return -1
	func wait_to_finish() -> Variant:
		GDRx.raise_message("Do not join the Main Thread Dummy!")
		return null
	func _to_string():
		return "MAIN_THREAD::" + str(GDRx.MAIN_THREAD_ID)
	func get_id() -> String:
		return str(GDRx.MAIN_THREAD_ID)
	func is_started() -> bool:
		return true
	func is_alive() -> bool:
		return true

## ID -> [Thread]
var _running_thread_ids : Dictionary = {}
## [Thread] -> ID
var _registered_threads : Dictionary = {}
## Re-entrant lock maintained by the singleton
var _lock : RLock = RLock.new()

## Registeres a new [Thread]. 
## This means it is known to GDRx and can be returned by [method get_current_thread]
## It is also automatically joined when not alive anymore.
func register_thread(thread : Thread):
	var id : int = OS.get_thread_caller_id()
	self._lock.lock()
	self._running_thread_ids[id] = thread
	self._registered_threads[thread] = id
	self._lock.unlock()

func _join_finished_threads():
	self._lock.lock()
	var registered_threads_ = self._registered_threads.keys()
	for thread in registered_threads_:
		var tid : int = self._registered_threads[thread]
		if thread.is_started() and not thread.is_alive():
			thread.wait_to_finish()
			self._registered_threads.erase(thread)
			if self._running_thread_ids[tid] == thread:
				self._running_thread_ids.erase(tid)
	self._lock.unlock()

func _ready():
	var action = func(__ = null, ___ = null):
		_join_finished_threads()
	Disposable.new(TimeoutScheduler.singleton().schedule_periodic(
		THREAD_JOIN_INTERVAL, action, 0).dispose).dispose_with(self)

## Returns the caller's current [Thread]
## If no thread object is registered this function returns [b]MAIN_THREAD[/b]
## implying that the caller is the main thread.
func get_current_thread() -> Thread:
	var result : Thread = null
	var id : int = OS.get_thread_caller_id()
	if id == MAIN_THREAD_ID:
		return MAIN_THREAD
	
	self._lock.lock()
	result = self._running_thread_ids[id]
	self._lock.unlock()
	
	return result

# =========================================================================== #
#   Scheduler Singletons
# =========================================================================== #

## [ImmediateScheduler] Singleton; [color=red]Do [b]NOT[/b] access directly![/color]
var ImmediateScheduler_ : ImmediateScheduler = ImmediateScheduler.new("GDRx")
## [TimeoutScheduler] Singleton; [color=red]Do [b]NOT[/b] access directly![/color]
var TimeoutScheduler_ : TimeoutScheduler = TimeoutScheduler.new("GDRx")
## [SceneTreeTimeoutScheduler] Singleton; [color=red]Do [b]NOT[/b] access directly![/color]
var SceneTreeTimeoutScheduler_ : SceneTreeTimeoutScheduler = SceneTreeTimeoutScheduler.new("GDRx")
## [ThreadedTimeoutScheduler] Singleton; [color=red]Do [b]NOT[/b] access directly![/color]
var ThreadedTimeoutScheduler_ : ThreadedTimeoutScheduler = ThreadedTimeoutScheduler.new("GDRx")
## [GodotSignalScheduler] Singleton; [color=red]Do [b]NOT[/b] access directly![/color]
var GodotSignalScheduler_ : GodotSignalScheduler = GodotSignalScheduler.new("GDRx")

## Global singleton of [CurrentThreadScheduler]
var CurrentThreadScheduler_global_ : WeakKeyDictionary = WeakKeyDictionary.new()
## Thread local singleton of [CurrentThreadScheduler]
var CurrentThreadScheduler_local_ = CurrentThreadScheduler._Local.new()

# =========================================================================== #
#   Exception Handler Singleton
# =========================================================================== #
## [ExceptionHandler] singleton; [color=red]Leave it alone![/color]
var ExceptionHandler_ : WeakKeyDictionary = WeakKeyDictionary.new()

# =========================================================================== #
#  Helper functions
# =========================================================================== #

## Equality
func eq(x, y) -> bool:
	return GDRx.basic.default_comparer(x, y)
## Negated equality
func neq(x, y) -> bool:
	return !eq(x, y)
## Less than operator
func lt(x, y) -> bool:
	return x.lt(y) if (x is Object and x.has_method("lt")) else x < y
## Greater than operator
func gt(x, y) -> bool:
	return x.gt(y) if (x is Object and x.has_method("gt")) else x > y
## Greater than equals operator
func gte(x, y) -> bool:
	return x.gte(y) if (x is Object and x.has_method("gte")) else x >= y
## Less than equals operator
func lte(x, y) -> bool:
	return x.lte(y) if (x is Object and x.has_method("lte")) else x <= y

## Raises a [code]GDRx.exc.AssertionFailedException[/code] and returns [b]true[/b]
## should the assertion fail.
func assert_(assertion : bool, message : String = "Assertion failed!") -> bool:
	if not assertion: 
		GDRx.exc.AssertionFailedException.new(message).throw()
	return not assertion

## Creates a new [TryCatch] Statement
func try(fun : Callable) -> TryCatch:
	return TryCatch.new(fun)

## Raises a [ThrowableBase]
func raise(exc_ : ThrowableBase, default = null) -> Variant:
	return ExceptionHandler.singleton().raise(exc_, default)

## Raises a [code]GDRx.exc.Exception[/code] containing the given message
func raise_message(msg : String, default = null):
	return exc.raise(msg, default)

## Blocks access to the function [code]fun[/code] using the given lock [code]l[/code]
func with(l, fun : Callable = func():return):
	return concur.with(l, fun)

## Creates an [ArrayIterator] from a given [Array]
func iter(x : Array, start : int = 0, end : int = -1) -> IterableBase:
	return util.Iter(x, start, end)

## Creates a [code]WhileIterator[/code] from a given condition and another iterator
func take_while(cond : Callable, it : IterableBase) -> IterableBase:
	return util.TakeWhile(cond, it)

## Generates an infinite sequence of a given value
func infinite(infval = NOT_SET) -> IterableBase:
	return util.Infinite(infval)

## NOT Set value
var NOT_SET = util.GetNotSet()

## NOT Set value
func not_set():
	return NOT_SET

## Alias for [code]GDRx.util.AddRef()[/code]
func add_ref(xs : Observable, r : RefCountDisposable) -> Observable:
	return util.AddRef(xs, r)

## Create an observable sequence from an array
func of(data : Array, scheduler : SchedulerBase = null) -> Observable:
	return self.from_array(data, scheduler)

## Alias for [code]GDRx.obs.return_value[/code]
func just(value, scheduler : SchedulerBase = null) -> Observable:
	return self.return_value(value, scheduler)

## Empty operation as defined in [code]GDRx.basic.noop[/code]
func noop(__ = null, ___ = null):
	GDRx.basic.noop(__, ___)

## Identity mapping as defined in [code]GDRx.basic.identity[/code]
func identity(x, __ = null):
	return GDRx.basic.identity(x, __)

# =========================================================================== #
#   Observable Constructors
# =========================================================================== #

## See: [b]res://reactivex/observable/amb.gd[/b]
func amb(sources : Array[Observable]) -> Observable:
	return obs.amb(sources)

## See: [b]res://reactivex/observable/case.gd[/b]
func case(mapper : Callable, sources : Dictionary, default_source : Observable = null) -> Observable:
	return obs.case(mapper, sources, default_source)

## Create a new observable
func create(subscribe : Callable = func(observer : ObserverBase, scheduler : SchedulerBase = null) -> DisposableBase: return Disposable.new()) -> Observable:
	return Observable.new(subscribe)

## See: [b]res://reactivex/observable/catch.gd[/b]
func catch(sources : Array) -> Observable:
	return obs.catch_with_iterable(GDRx.util.Iter(sources))

## See: [b]res://reactivex/observable/catch.gd[/b]
func catch_with_iterable(sources : IterableBase) -> Observable:
	return obs.catch_with_iterable(sources)

## See: [b]res://reactivex/observable/combinelatest.gd[/b]
func combine_latest(sources : Array[Observable]) -> Observable:
	return obs.combine_latest(sources)

## See: [b]res://reactivex/observable/concat.gd[/b]
func concat_streams(sources : Array) -> Observable:
	return obs.concat_with_iterable(GDRx.util.Iter(sources))

## See: [b]res://reactivex/observable/concat.gd[/b]
func concat_with_iterable(sources : IterableBase) -> Observable:
	return obs.concat_with_iterable(sources)

## See: [b]res://reactivex/observable/defer.gd[/b]
func defer(factory : Callable = GDRx.basic.default_factory) -> Observable:
	return obs.defer(factory)

## See: [b]res://reactivex/observable/empty.gd[/b]
func empty(scheduler : SchedulerBase = null) -> Observable:
	return obs.empty(scheduler)

## See: [b]res://reactivex/observable/forkjoin.gd[/b]
func fork_join(sources : Array[Observable]) -> Observable:
	return obs.fork_join(sources)

## See: [b]res://reactivex/observable/fromcallback.gd[/b]
func from_callback(fun : Callable = func(args : Array, cb : Callable): return, mapper = null) -> Callable:
	return obs.from_callback(fun, mapper)

## Transforms an array into an observable sequence.
func from_array(array : Array, scheduler : SchedulerBase = null) -> Observable:
	return obs.from_iterable(GDRx.util.Iter(array), scheduler)

## See: [b]res://reactivex/observable/fromiterable.gd[/b]
func from_iterable(iterable : IterableBase, scheduler : SchedulerBase = null) -> Observable:
	return obs.from_iterable(iterable, scheduler)

## See: [b]res://reactivex/observable/generate.gd[/b]
func generate(initial_state, condition : Callable = GDRx.basic.default_condition, iterate : Callable = GDRx.basic.identity) -> Observable:
	return obs.generate(initial_state, condition, iterate)

## See: [b]res://reactivex/observable/generatewithrealtivetime.gd[/b]
func generate_with_relative_time(initial_state, condition : Callable = GDRx.basic.default_condition, iterate : Callable = GDRx.basic.identity, time_mapper : Callable = func(state) -> float: return 1.0) -> Observable:
	return obs.generate_with_relative_time(initial_state, condition, iterate, time_mapper)

## See: [b]res://reactivex/observable/ifthen.gd[/b]
func if_then(condition : Callable = GDRx.basic.default_condition, then_source : Observable = null, else_source : Observable = null) -> Observable:
	return obs.if_then(condition, then_source, else_source)

## See: [b]res://reactivex/observable/interval.gd[/b]
func interval(period : float, scheduler : SchedulerBase = null) -> ObservableBase:
	return obs.interval(period, scheduler)

## See: [b]res://reactivex/observable/merge.gd[/b]
func merge(sources : Array[Observable]) -> Observable:
	return obs.merge(sources)

## See: [b]res://reactivex/observable/never.gd[/b]
func never() -> Observable:
	return obs.never()

## See: [b]res://reactivex/observable/onerrorresumenext.gd[/b]
func on_error_resume_next(sources : Array) -> Observable:
	return obs.on_error_resume_next(sources)

## See: [b]res://reactivex/observable/range.gd[/b]
@warning_ignore("shadowed_global_identifier")
func range(start : int, stop = null, step = null, scheduler : SchedulerBase = null) -> Observable:
	return obs.range(start, stop, step, scheduler)

## See: [b]res://reactivex/observable/repeat.gd[/b]
func repeat_value(value, repeat_count = null) -> Observable:
	return obs.repeat_value(value, repeat_count)

## See: [b]res://reactivex/observable/returnvalue.gd[/b]
func return_value(value, scheduler : SchedulerBase = null) -> Observable:
	return obs.return_value(value, scheduler)

## See: [b]res://reactivex/observable/returnvalue.gd[/b]
func return_value_from_callback(supplier : Callable, scheduler : SchedulerBase = null) -> Observable:
	return obs.return_value_from_callback(supplier, scheduler)

## See: [b]res://reactivex/observable/throw.gd[/b]
func throw(err, scheduler : SchedulerBase = null) -> Observable:
	return obs.throw(err, scheduler)

## See: [b]res://reactivex/observable/timer.gd[/b]
func timer(duetime : float, time_absolute : bool, period = null, scheduler : SchedulerBase = null) -> Observable:
	return obs.timer(duetime, time_absolute, period, scheduler)

## See: [b]res://reactivex/observable/toasync.gd[/b]
func to_async(fun : Callable, scheduler : SchedulerBase = null) -> Callable:
	return obs.to_async(fun, scheduler)

## See: [b]res://reactivex/observable/using.gd[/b]
func using(resource_factory : Callable, observable_factory : Callable) -> Observable:
	return obs.using(resource_factory, observable_factory)

## See: [b]res://reactivex/observable/withlatestfrom.gd[/b]
func with_latest_from(sources : Array[Observable]) -> Observable:
	var _sources : Array[Observable] = sources.duplicate()
	var parent = _sources.pop_front()
	return obs.with_latest_from(parent, _sources)

## See: [b]res://reactivex/observable/zip.gd[/b]
func zip(sources : Array[Observable]) -> Observable:
	return obs.zip(sources)

# =========================================================================== #
#   Timers
# =========================================================================== #

var _timeout = TimeoutScheduler.TimeoutType.new()

## Collection of [SceneTreeTimeoutScheduler]s, see: [TimeoutScheduler.TimeoutType]
## for more information!
var timeout:
	get: return self._timeout

## Creates an observable timer
func start_timer(timespan_sec : float, scheduler : SchedulerBase = null) -> Observable:
	return obs.timer(timespan_sec, false, null, scheduler)

## Creates an observable periodic timer
func start_periodic_timer(period_sec : float, scheduler : SchedulerBase = null) -> Observable:
	return obs.timer(period_sec, false, period_sec, scheduler)

## Creates an observable periodic timer which starts after a timespan has passed
func start_periodic_timer_after_timespan(timespan_sec : float, period_sec : float, scheduler : SchedulerBase = null) -> Observable:
	return obs.timer(timespan_sec, false, period_sec, scheduler)

## Creates an observable timer
func schedule_datetime(datetime_sec : float, scheduler : SchedulerBase = null) -> Observable:
	return obs.timer(datetime_sec, true, null, scheduler)

## Creates an observable periodic timer which starts at a given timestamp.
func start_periodic_timer_at_datetime(datetime_sec : float, period_sec : float, scheduler : SchedulerBase = null) -> Observable:
	return obs.timer(datetime_sec, true, period_sec, scheduler)

# =========================================================================== #
#   Godot-specific Observable Constructors
# =========================================================================== #

## Creates an observable from a Godot Signal
func from_signal(sig : Signal) -> Observable:
	return gd.from_godot_signal(sig)

## Creates an observable from a Coroutine
func from_coroutine(fun : Callable, bindings : Array = [], scheduler : SchedulerBase = null) -> Observable:
	return gd.from_godot_coroutine(fun, bindings, scheduler)

## Emits items from [method Node._process].
func on_process_as_observable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 0)

## Emits items from [method Node._physics_process].
func on_physics_process_as_observable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 1)

## Emits items from [method Node._input].
func on_input_as_observable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 2)

## Emits items from [method Node._shortcut_input].
func on_shortcut_input_as_observable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 3)

## Emits items from [method Node._unhandled_input].
func on_unhandled_input_as_observable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 4)

## Emits items from [method Node._unhandled_key_input].
func on_unhandled_key_input_as_observable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 5)

## Tranforms an input action into an observable sequence emiting items on check.
func input_action(input_action_ : String, checks : Observable) -> Observable:
	return gd.from_godot_input_action(input_action_, checks)

## Creates a new Compute Shader as [Observable].
func from_compute_shader(shader_path : String, rd : RenderingDevice, work_groups : Vector3i, uniform_sets : Array = [], scheduler : SchedulerBase = null) -> Observable:
	return gd.from_compute_shader(shader_path, rd, work_groups, uniform_sets, scheduler)

## Emits items when the node enters the scene tree
func on_tree_enter_as_observable(node : Node) -> Observable:
	return from_signal(node.tree_entered)

## Emits items when the node just exited the scene tree
func on_tree_exit_as_observable(node : Node) -> Observable:
	return from_signal(node.tree_exited)

## Emits items when the node is about to exit the scene tree
func on_tree_exiting_as_observable(node : Node) -> Observable:
	return from_signal(node.tree_exiting)

## Creates an HTTP Request
func from_http_request(url : String, request_data = "", raw : bool = false, encoding : String = "", requester : HTTPRequest = null, custom_headers : PackedStringArray = PackedStringArray(), tls_validate_domain : bool = true, method : HTTPClient.Method = 0) -> Observable:
	return gd.from_http_request(url, request_data, raw, encoding, requester, custom_headers, tls_validate_domain, method)

# =========================================================================== #
#   Some useful Input Observables
# =========================================================================== #

## Emits item when mouse button is just pressed
func on_mouse_down() -> Observable:
	return on_input_as_observable(self) \
		.filter(func(ev : InputEvent): return ev is InputEventMouseButton) \
		.filter(func(ev : InputEventMouseButton): return ev.is_pressed())

## Emits item when mouse button is just released
func on_mouse_up() -> Observable:
	return on_input_as_observable(self) \
		.filter(func(ev : InputEvent): return ev is InputEventMouseButton) \
		.filter(func(ev : InputEventMouseButton): return not ev.is_pressed())

## Emits item on mouse double-click
func on_mouse_double_click() -> Observable:
	return on_input_as_observable(self) \
		.filter(func(ev : InputEvent): return ev is InputEventMouseButton) \
		.filter(func(ev : InputEventMouseButton): return ev.is_pressed() and ev.double_click)

## Emits items on mouse motion
func on_mouse_motion() -> Observable:
	return on_input_as_observable(self) \
		.filter(func(ev : InputEvent): return ev is InputEventMouseMotion)

## Emits the relative mouse motion as a [Vector2].
func relative_mouse_movement_as_observable() -> Observable:
	return on_input_as_observable(self) \
		.filter(func(ev : InputEvent): return ev is InputEventMouseMotion) \
		.map(func(ev : InputEventMouseMotion): return ev.relative)

## Emits an item when the given keycode is just pressed.
func on_key_just_pressed(key : int) -> Observable:
	return on_input_as_observable(self) \
		.filter(func(ev : InputEvent): return ev is InputEventKey) \
		.filter(func(ev : InputEventKey): return ev.keycode == key and ev.pressed and not ev.echo)

## Emits an item when the given keycode is pressed.
func on_key_pressed(key : int) -> Observable:
	return on_input_as_observable(self) \
		.filter(func(ev : InputEvent): return ev is InputEventKey) \
		.filter(func(ev : InputEventKey): return ev.keycode == key and ev.pressed)

## Emits an item when the given keycode is just released.
func on_key_just_released(key : int) -> Observable:
	return on_input_as_observable(self) \
		.filter(func(ev : InputEvent): return ev is InputEventKey) \
		.filter(func(ev : InputEventKey): return ev.keycode == key and not ev.pressed)

## Emits an item, when the screen is touched (touch devices).
func on_screen_touch() -> Observable:
	return on_input_as_observable(self) \
		.filter(func(ev : InputEvent): return ev is InputEventScreenTouch)

## Emits an item, when the touch screen notices a drag gesture (touch devices)
func on_screen_drag() -> Observable:
	return on_input_as_observable(self) \
		.filter(func(ev : InputEvent): return ev is InputEventScreenDrag)

## Emits an item on Midi event.
func on_midi_event() -> Observable:
	return on_input_as_observable(self) \
		.filter(func(ev : InputEvent): return ev is InputEventMIDI)

## Emits an item, when a joypad button is just pressed.
func on_joypad_button_down() -> Observable:
	return on_input_as_observable(self) \
		.filter(func(ev : InputEvent): return ev is InputEventJoypadButton) \
		.filter(func(ev : InputEventJoypadButton): return not ev.is_echo() and ev.is_pressed())

## Emits an item, when a joypad button is pressed.
func on_joypad_button_pressed() -> Observable:
	return on_input_as_observable(self) \
		.filter(func(ev : InputEvent): return ev is InputEventJoypadButton) \
		.filter(func(ev : InputEventJoypadButton): return ev.is_pressed())

## Emits an item, when a joypad button is just released.
func on_joypad_button_released() -> Observable:
	return on_input_as_observable(self) \
		.filter(func(ev : InputEvent): return ev is InputEventJoypadButton) \
		.filter(func(ev : InputEventJoypadButton): return not ev.is_pressed())

# =========================================================================== #
#   Frame Events
# =========================================================================== #

## Emits items on idle frame events.
func on_idle_frame() -> Observable:
	return from_signal(self.get_tree().process_frame) \
		.map(func(__): return get_process_delta_time())

## Emits items on physics frame events.
func on_physics_step() -> Observable:
	return from_signal(self.get_tree().physics_frame) \
		.map(func(__): return get_physics_process_delta_time())

## Emits an item when the scene tree has changed.
func on_tree_changed() -> Observable:
	return from_signal(self.get_tree().tree_changed)

## Emits an item at post-draw frame event.
func on_frame_post_draw() -> Observable:
	return from_signal(RenderingServer.frame_post_draw)

## Emits an item at pre-draw frame event.
func on_frame_pre_draw() -> Observable:
	return from_signal(RenderingServer.frame_pre_draw)
