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

## Dummy class to represent the main [Thread] instance
class _MainThreadDummy extends Thread:
	func start(_callable : Callable, _priority : int = 1) -> int:
		GDRx.raise_message("Do not launch the Main Thread Dummy!")
		return -1
	func _to_string():
		return "MAIN_THREAD::" + str(GDRx.MAIN_THREAD_ID)

## ID of the main thread
var MAIN_THREAD_ID = OS.get_thread_caller_id()
## Dummy instance for the Main Thread
var MAIN_THREAD = _MainThreadDummy.new()

## ID -> [Thread]
var running_threads : Dictionary = {}
## All registered [Thread] instances ready for joining stored as their id
var finished_threads : Array[Thread]

## Re-entrant lock maintained by the singleton
var lock : RLock = RLock.new()

## Registeres a new [Thread]. 
## This means it is known to GDRx and can be returned by [method get_current_thread]
func register_thread(thread : Thread):
	var id : int = OS.get_thread_caller_id()
	self.lock.lock()
	self.running_threads[id] = thread
	self.lock.unlock()

## Schedules a [Thread] for automatic join. Afterwards it cannot be retuned by 
## [method get_current_thread] anymore
func deregister_thread(thread : Thread):
	var id : int = OS.get_thread_caller_id()
	self.lock.lock()
	self.running_threads.erase(id)
	self.finished_threads.append(thread)
	self.lock.unlock()

func _join_finished_threads():
	var finished_threads_ : Array[Thread] = []
	
	self.lock.lock()
	for thread in self.finished_threads.duplicate():
		if thread.is_started():
			finished_threads_.append(thread)
		self.finished_threads.erase(thread)
	self.lock.unlock()
	
	for t in finished_threads_:
		t.wait_to_finish()

func _process(_delta):
	_join_finished_threads()

## Returns the caller's current [Thread]
## If no thread object is registered this function returns [b]MAIN_THREAD[/b]
## implying that the caller is the main thread.
func get_current_thread() -> Thread:
	var result : Thread = null
	var id : int = OS.get_thread_caller_id()
	if id == MAIN_THREAD_ID:
		return MAIN_THREAD
	
	self.lock.lock()
	result = self.running_threads[id]
	self.lock.unlock()
	
	return result

# =========================================================================== #
#   Scheduler Singletons
# =========================================================================== #

## [ImmediateScheduler] Singleton [color=red]Do [b]NOT[/b] access directly![/color]
var ImmediateScheduler_ : ImmediateScheduler = ImmediateScheduler.new("GDRx")
## [TimeoutScheduler] Singleton [color=red]Do [b]NOT[/b] access directly![/color]
var TimeoutScheduler_ : TimeoutScheduler = TimeoutScheduler.new("GDRx")
## [GodotSignalScheduler] Singleton [color=red]Do [b]NOT[/b] access directly![/color]
var GodotSignalScheduler_ : GodotSignalScheduler = GodotSignalScheduler.new("GDRx")

## Global singleton of [CurrentThreadScheduler]
var CurrentThreadScheduler_global_ : WeakKeyDictionary = WeakKeyDictionary.new()
## Thread local singleton of [CurrentThreadScheduler]
var CurrentThreadScheduler_local_ = CurrentThreadScheduler._Local.new()

# =========================================================================== #
#   Exception Handler Singleton
# =========================================================================== #
## [ExceptionHandler] singleton [color=red]Leave it alone![/color]
var ExceptionHandler_ : ExceptionHandler = ExceptionHandler.new("GDRx")

# =========================================================================== #
#  Helper functions
# =========================================================================== #

## Raises a [code]GDRx.exc.AssertionFailedException[/code] and returns [b]true[/b]
## should the assertion fail.
func assert_(assertion : bool) -> bool:
	if not assertion: 
		GDRx.exc.AssertionFailedException.Throw()
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
func defer(factory : Callable = func(scheduler : SchedulerBase) -> Observable: return null) -> Observable:
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
func generate(initial_state, condition : Callable = func(state) -> bool: return true, iterate : Callable = func(state): return state) -> Observable:
	return obs.generate(initial_state, condition, iterate)

## See: [b]res://reactivex/observable/generatewithrealtivetime.gd[/b]
func generate_with_relative_time(initial_state, condition : Callable = func(state) -> bool: return true, iterate : Callable = func(state): return state, time_mapper : Callable = func(state) -> float: return 1.0) -> Observable:
	return obs.generate_with_relative_time(initial_state, condition, iterate, time_mapper)

## See: [b]res://reactivex/observable/ifthen.gd[/b]
func if_then(then_source : Observable, else_source : Observable = null, condition : Callable = func() -> bool: return true) -> Observable:
	return obs.if_then(then_source, else_source, condition)

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
@warning_ignore(shadowed_global_identifier)
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
func using(resource_factory : Callable, observable_factory : Callable,) -> Observable:
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

## Creates a new [ReactiveProperty]
func reactive_property(value = null) -> ReactiveProperty:
	return ReactiveProperty.ChangedValue(value)

## Transforms a [ReactiveProperty] into a [ReadOnlyReactiveProperty]
func to_readonly(prop : ReactiveProperty) -> ReadOnlyReactiveProperty:
	return ReadOnlyReactiveProperty.new(prop)

## Creates an observable timer
func start_timer(timespan_sec : float) -> Observable:
	return obs.timer(timespan_sec, false)

## Creates an observable periodic timer
func start_periodic_timer(period_sec : float) -> Observable:
	return obs.timer(period_sec, false, period_sec)

## Creates an observable periodic timer which starts after a timespan has passed
func start_periodic_timer_after_timespan(timespan_sec : float, period_sec : float) -> Observable:
	return obs.timer(timespan_sec, false, period_sec)

## Creates an observable timer
func schedule_datetime(datetime_sec : float) -> Observable:
	return obs.timer(datetime_sec, true)

## Creates an observable periodic timer which starts at a given timestamp.
func start_periodic_timer_at_datetime(datetime_sec : float, period_sec : float) -> Observable:
	return obs.timer(datetime_sec, true, period_sec)
