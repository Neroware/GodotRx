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
## Access to pipe operators
var pipe = __init__.Pipe_.new()

# =========================================================================== #
#   Constructor/Destructor
# =========================================================================== #

func _init():
	## Insert Main Thread
	if true:
		var reglock : ReadWriteLock = self.THREAD_MANAGER.THREAD_REGISTRY.at(0)
		reglock.w_lock()
		self.THREAD_MANAGER.THREAD_REGISTRY.at(1)[MAIN_THREAD_ID] = MAIN_THREAD
		reglock.w_unlock()
	
	## Init [SceneTreeScheduler] singleton
	for i in range(8):
		var process_always : bool = bool(i & 0b1)
		var process_in_physics : bool = bool(i & 0b10)
		var ignore_time_scale : bool = bool(i & 0b100)
		self.SceneTreeTimeoutScheduler_.push_back(SceneTreeTimeoutScheduler.new(
			"GDRx", process_always, process_in_physics, ignore_time_scale))

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		self.THREAD_MANAGER.stop_and_join()
		self.THREAD_MANAGER.free()

# =========================================================================== #
#   Multi-Threading
# =========================================================================== #

## Dummy instance for the Main Thread
var MAIN_THREAD = concur.MainThreadDummy_.new()
## ID of the main thread
var MAIN_THREAD_ID = OS.get_thread_caller_id()
## Thread Manager
var THREAD_MANAGER = concur.ThreadManager.new()

## Returns the caller's current [Thread]
## If the caller thread is the main thread, it returns [b]MAIN_THREAD[/b].
func get_current_thread() -> Thread:
	var id = OS.get_thread_caller_id()
	var l : ReadWriteLock = self.THREAD_MANAGER.THREAD_REGISTRY.at(0)
	l.r_lock()
	id = self.THREAD_MANAGER.THREAD_REGISTRY.at(1)[id]
	l.r_unlock()
	return id

# =========================================================================== #
#   Scheduler Singletons
# =========================================================================== #

## [ImmediateScheduler] Singleton; [color=red]Do [b]NOT[/b] access directly![/color]
var ImmediateScheduler_ : ImmediateScheduler = ImmediateScheduler.new("GDRx")
## [SceneTreeTimeoutScheduler] Singleton; [color=red]Do [b]NOT[/b] access directly![/color]
var SceneTreeTimeoutScheduler_ : Array[SceneTreeTimeoutScheduler]
## [ThreadedTimeoutScheduler] Singleton; [color=red]Do [b]NOT[/b] access directly![/color]
var ThreadedTimeoutScheduler_ : ThreadedTimeoutScheduler = ThreadedTimeoutScheduler.new("GDRx")
## [NewThreadScheduler] Singleton; [color=red]Do [b]NOT[/b] access directly![/color]
var NewThreadScheduler_ : NewThreadScheduler = NewThreadScheduler.new(self.concur.default_thread_factory)
## [GodotSignalScheduler] Singleton; [color=red]Do [b]NOT[/b] access directly![/color]
var GodotSignalScheduler_ : GodotSignalScheduler = GodotSignalScheduler.new("GDRx")

## Global singleton of [CurrentThreadScheduler]
var CurrentThreadScheduler_global_ : WeakKeyDictionary = WeakKeyDictionary.new()
## Thread local singleton of [CurrentThreadScheduler]
var CurrentThreadScheduler_local_ = CurrentThreadScheduler._Local.new()

# =========================================================================== #
#   Error Handler Singleton
# =========================================================================== #
## [ErrorHandler] singleton; [color=red]Leave it alone![/color]
var ErrorHandler_ : WeakKeyDictionary = WeakKeyDictionary.new()

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

## Raises a [AssertionFailedError] and returns [b]true[/b]
## should the assertion fail.
func assert_(assertion : bool, message : String = "Assertion failed!") -> bool:
	if not assertion: 
		AssertionFailedError.new(message).throw()
	return not assertion

## Creates a new [TryCatch] Statement
func try(fun : Callable) -> TryCatch:
	return TryCatch.new(fun)

## Raises a [ThrowableBase]
func raise(exc_ : ThrowableBase, default = null) -> Variant:
	return ErrorHandler.singleton().raise(exc_, default)

## Raises a [RxBaseError] containing the given message
func raise_message(msg : String, default = null):
	return RxBaseError.raise(default, msg)

## Construct an [IterableBase] onto x.
func to_iterable(x) -> IterableBase:
	return Iterator.to_iterable(x)

### Construct an [Iterator] onto x.
func iter(x) -> Iterator:
	return Iterator.iter(x)

### Creates a [WhileIterable] from a given condition and another [IterableBase]
func take_while(cond : Callable, it : IterableBase) -> IterableBase:
	return WhileIterable.new(it, cond)

### Generates an [InfiniteIterable] sequence of a given value.
func infinite(infval = NOT_SET) -> IterableBase:
	return InfiniteIterable.new(infval)

### NOT Set value
var NOT_SET:
	get: return util.NOT_SET

## Is NOT Set value
func not_set(value) -> bool:
	return NOT_SET.eq(value)

## Unit item
var UNIT:
	get: return StreamItem.Unit()

## Alias for [code]GDRx.util.add_ref()[/code]
func add_ref(xs : Observable, r : RefCountDisposable) -> Observable:
	return util.add_ref(xs, r)

## Create an observable sequence from an array
func of(data : Array, scheduler : SchedulerBase = null) -> Observable:
	return self.from_array(data, scheduler)

## Create an observable on any given iterable sequence
func from(seq, scheduler : SchedulerBase = null) -> Observable:
	return self.from_iterable(to_iterable(seq), scheduler)

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

## See: [b]res://addons/reactivex/observable/amb.gd[/b]
func amb(sources) -> Observable:
	return obs.amb(sources)

## See: [b]res://addons/reactivex/observable/case.gd[/b]
func case(mapper : Callable, sources : Dictionary, default_source : Observable = null) -> Observable:
	return obs.case(mapper, sources, default_source)

## Create a new observable
func create(subscribe : Callable = func(_observer : ObserverBase, _scheduler : SchedulerBase = null) -> DisposableBase: return Disposable.new()) -> Observable:
	return Observable.new(subscribe)

## See: [b]res://addons/reactivex/observable/catch.gd[/b]
func catch(sources : Array[Observable]) -> Observable:
	return obs.catch_with_iterable(to_iterable(sources))

## See: [b]res://addons/reactivex/observable/catch.gd[/b]
func catch_with_iterable(sources : IterableBase) -> Observable:
	return obs.catch_with_iterable(sources)

## See: [b]res://addons/reactivex/observable/combinelatest.gd[/b]
func combine_latest(sources) -> Observable:
	return obs.combine_latest(sources)

## See: [b]res://addons/reactivex/observable/concat.gd[/b]
func concat_streams(sources : Array[Observable]) -> Observable:
	return obs.concat_with_iterable(to_iterable(sources))

## See: [b]res://addons/reactivex/observable/concat.gd[/b]
func concat_with_iterable(sources : IterableBase) -> Observable:
	return obs.concat_with_iterable(sources)

## See: [b]res://addons/reactivex/observable/defer.gd[/b]
func defer(factory : Callable = GDRx.basic.default_factory) -> Observable:
	return obs.defer(factory)

## See: [b]res://addons/reactivex/observable/empty.gd[/b]
func empty(scheduler : SchedulerBase = null) -> Observable:
	return obs.empty(scheduler)

## See: [b]res://addons/reactivex/observable/forkjoin.gd[/b]
func fork_join(sources) -> Observable:
	return obs.fork_join(sources)

## See: [b]res://addons/reactivex/observable/fromcallback.gd[/b]
func from_callback(fun : Callable = func(_args : Array, _cb : Callable): return, mapper = null) -> Callable:
	return obs.from_callback(fun, mapper)

## Transforms an array into an observable sequence.
func from_array(array : Array, scheduler : SchedulerBase = null) -> Observable:
	return obs.from_iterable(to_iterable(array), scheduler)

## See: [b]res://addons/reactivex/observable/fromiterable.gd[/b]
func from_iterable(iterable : IterableBase, scheduler : SchedulerBase = null) -> Observable:
	return obs.from_iterable(iterable, scheduler)

## See: [b]res://addons/reactivex/observable/generate.gd[/b]
func generate(initial_state, condition : Callable = GDRx.basic.default_condition, iterate : Callable = GDRx.basic.identity) -> Observable:
	return obs.generate(initial_state, condition, iterate)

## See: [b]res://addons/reactivex/observable/generatewithrealtivetime.gd[/b]
func generate_with_relative_time(initial_state, condition : Callable = GDRx.basic.default_condition, iterate : Callable = GDRx.basic.identity, time_mapper : Callable = func(_state) -> float: return 1.0) -> Observable:
	return obs.generate_with_relative_time(initial_state, condition, iterate, time_mapper)

## See: [b]res://addons/reactivex/observable/ifthen.gd[/b]
func if_then(condition : Callable = GDRx.basic.default_condition, then_source : Observable = null, else_source : Observable = null) -> Observable:
	return obs.if_then(condition, then_source, else_source)

## See: [b]res://addons/reactivex/observable/interval.gd[/b]
func interval(period : float, scheduler : SchedulerBase = null) -> ObservableBase:
	return obs.interval(period, scheduler)

## See: [b]res://addons/reactivex/observable/merge.gd[/b]
func merge(sources) -> Observable:
	return obs.merge(sources)

## See: [b]res://addons/reactivex/observable/never.gd[/b]
func never() -> Observable:
	return obs.never()

## See: [b]res://addons/reactivex/observable/onerrorresumenext.gd[/b]
func on_error_resume_next(sources : Array) -> Observable:
	return obs.on_error_resume_next(sources)

## See: [b]res://addons/reactivex/observable/range.gd[/b]
@warning_ignore("shadowed_global_identifier")
func range(start : int, stop = null, step = null, scheduler : SchedulerBase = null) -> Observable:
	return obs.range(start, stop, step, scheduler)

## See: [b]res://addons/reactivex/observable/repeat.gd[/b]
func repeat_value(value, repeat_count = null) -> Observable:
	return obs.repeat_value(value, repeat_count)

## See: [b]res://addons/reactivex/observable/returnvalue.gd[/b]
func return_value(value, scheduler : SchedulerBase = null) -> Observable:
	return obs.return_value(value, scheduler)

## See: [b]res://addons/reactivex/observable/returnvalue.gd[/b]
func from_callable(supplier : Callable, scheduler : SchedulerBase = null) -> Observable:
	return obs.from_callable(supplier, scheduler)

## See: [b]res://addons/reactivex/observable/throw.gd[/b]
func throw(err, scheduler : SchedulerBase = null) -> Observable:
	return obs.throw(err, scheduler)

## See: [b]res://addons/reactivex/observable/timer.gd[/b]
func timer(duetime : float, time_absolute : bool, period = null, scheduler : SchedulerBase = null) -> Observable:
	return obs.timer(duetime, time_absolute, period, scheduler)

## See: [b]res://addons/reactivex/observable/toasync.gd[/b]
func to_async(fun : Callable, scheduler : SchedulerBase = null) -> Callable:
	return obs.to_async(fun, scheduler)

## See: [b]res://addons/reactivex/observable/using.gd[/b]
func using(resource_factory : Callable, observable_factory : Callable) -> Observable:
	return obs.using(resource_factory, observable_factory)

## See: [b]res://addons/reactivex/observable/withlatestfrom.gd[/b]
func with_latest_from(sources) -> Observable:
	var _sources : Array[Observable] = util.unpack_arg(sources)
	assert_(_sources.size() > 0)
	var parent = _sources.pop_front()
	return obs.with_latest_from(parent, _sources)

## See: [b]res://addons/reactivex/observable/zip.gd[/b]
func zip(sources) -> Observable:
	return obs.zip(sources)

# =========================================================================== #
#   Timers
# =========================================================================== #

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
func from_http_request(url : String, request_data = "", raw : bool = false, encoding : String = "", requester : HTTPRequest = null, custom_headers : PackedStringArray = PackedStringArray(), method : HTTPClient.Method = HTTPClient.METHOD_GET) -> Observable:
	return gd.from_http_request(url, request_data, raw, encoding, requester, custom_headers, method)

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
