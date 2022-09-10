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
## Error types
var err = __init__.Error_.new()
## Basic functions & types
var basic = __init__.Basic_.new()
## Concurrency functions & types
var concur = __init__.Concurrency_.new()
## Utility functions & types
var util = __init__.Util_.new()
## Access to pipe operators
var pipe = __init__.Pipe_.new()

# =========================================================================== #
#   Scheduler Singletons
# =========================================================================== #
var ImmediateScheduler_ : ImmediateScheduler = ImmediateScheduler.new("GDRx")
var TimeoutScheduler_ : TimeoutScheduler = TimeoutScheduler.new("GDRx")
var GodotSignalScheduler_ : GodotSignalScheduler = GodotSignalScheduler.new("GDRx")

var CurrentThreadScheduler_global_ : WeakRefDictionary = WeakRefDictionary.new()
var CurrentThreadScheduler_local_ = CurrentThreadScheduler._Local.new()

# =========================================================================== #
#  Helper functions
# =========================================================================== #
## Create an iterable sequence from an array
func iter(data : Array) -> IterableBase:
	return GDRx.util.Iter(data)

## Create an observable sequence from an array
func of(data : Array) -> Observable:
	return self.FromArray(data)

## Alias for GDRx.obs.return_value
func just(value, scheduler : SchedulerBase = null) -> Observable:
	return self.ReturnValue(value, scheduler)

# =========================================================================== #
#   Observable Constructors
# =========================================================================== #

## Create a new observable
func Create(subscribe : Callable = func(observer : ObserverBase, scheduler : SchedulerBase = null) -> DisposableBase: return Disposable.new()) -> Observable:
	return Observable.new(subscribe)

## Create an empty observable
func Empty(scheduler : SchedulerBase = null) -> Observable:
	return obs.empty(scheduler)

## Create an observale which never emits an item.
func Never(scheduler : SchedulerBase = null) -> Observable:
	return obs.never()

## Create an observable which throws an error.
func Throw(err, scheduler : SchedulerBase = null) -> Observable:
	return obs.throw(err, scheduler)

## Create an observable which retuns a given value
func ReturnValue(value, scheduler : SchedulerBase = null) -> Observable:
	return obs.return_value(value, scheduler)

## Create an observable from a callback function. Return value is given back on
## the stream.
func FromCallback(supplier : Callable, scheduler : SchedulerBase = null) -> Observable:
	return obs.return_value_from_callback(supplier, scheduler)

## Create an observable which only emits items from the observable sequence
## which first emitted an item.
func WinnerOf(observables : Array[Observable]) -> Observable:
	return obs.amb(observables)

## Builds a new observable from a factory-function. (See hot and cold observables)
func BuildDeferred(factory : Callable = func(scheduler : SchedulerBase) -> Observable: return null) -> Observable:
	return obs.defer(factory)

## Creates an observable resembling a switch-case-statement.
func SwitchCase(mapper : Callable, sources : Dictionary, default_source : Observable = null) -> Observable:
	return obs.case(mapper, sources, default_source)

## Creates an Observable that continues with the next observable in the given
## array when an error is thrown.
func CatchAndContinueWith(sources : Array[Observable]) -> Observable:
	return obs.catch_with_iterable(GDRx.util.Iter(sources))

## Creates an Observable that continues with the next observable in the given
## iterable sequence when an error is thrown.
func CatchAndContinueWithIterable(sources : IterableBase) -> Observable:
	return obs.catch_with_iterable(sources)

## Creates an Observable that combines all latest stream items of all given 
## observables into [Tuple]s emitted on the stream.
func CombineLatestOf(sources : Array[Observable]) -> Observable:
	if sources.is_empty():
		return Empty()
	if sources.size() == 1:
		return sources[0]
	return obs.combine_latest(sources)

## Creates an Observable that continues with the next observable in the given
## array when the previous observable has finished.
func ConcatStreams(sources : Array[Observable]) -> Observable:
	return obs.concat_with_iterable(GDRx.util.Iter(sources))

## Creates an Observable that continues with the next observable in the given
## iterable sequence when the previous observable has finished.
func ConcatStreamsWithIterable(sources : IterableBase) -> Observable:
	return obs.concat_with_iterable(sources)

## Creates an observable which emits all final items from all observable streams 
## after all completed. If a sequence completes before emitting an item,
## the join will also immediatly complete.
func ForkJoin(sources : Array[Observable]) -> Observable:
	return obs.fork_join(sources)

## Creates a function which when called returns an observable which emits the
## functions's return value the stream.
func BuildFromCallback(fun : Callable = func(args : Array, cb : Callable): return, mapper : Callable = func(args): return args) -> Callable:
	return obs.from_callback(fun, mapper)

## Transforms an array into an observable sequence.
func FromArray(array : Array) -> Observable:
	return obs.from_iterable(GDRx.util.Iter(array))

## Transforms an iterable into an observable sequence.
func FromIterable(iterable : IterableBase) -> Observable:
	return obs.from_iterable(iterable)

## Generates an Observable from a given state
func GenerateFrom(initial_state, condition : Callable, iterate : Callable) -> Observable:
	return obs.generate(initial_state, condition, iterate)

## Generates an Observable from a given state using a time-mapper
func GenerateWithRealtiveTime(initial_state, condition : Callable, iterate : Callable, time_mapper : Callable) -> Observable:
	return obs.generate_with_relative_time(initial_state, condition, iterate, time_mapper)

## Creates an Observable that emits items of [code]then_source[/code] when 
## the condition is met, otherwise items of [code]else_source[/code] are
## emitted.
func IfThenElse(then_source : Observable, else_source : Observable, condition : Callable = func() -> bool: return true) -> Observable:
	return obs.if_then(then_source, else_source, condition)

## Creates an Observable that emits items of [code]then_source[/code] when 
## the condition is met.
func IfThen(then_source : Observable, condition : Callable = func() -> bool: return true) -> Observable:
	return obs.if_then(then_source, null, condition)

## Creates an Observable that continues with the next observable in the given
## array when the previous is terminated.
func ResumeAfterTerminationWith(sources : Array) -> Observable:
	return obs.on_error_resume_next(sources)

## Transforms a range into an observable sequence
func FromRange(start : int, stop = null, step = null, scheduler : SchedulerBase = null) -> Observable:
	return obs.range(start, stop, step, scheduler)

## Builds an observable using resources from a given resource factory.
func BuildUsing(
		resource_factory : Callable = func() -> DisposableBase: return null, 
		observable_factory : Callable = func(disp : DisposableBase) -> DisposableBase: return GDRx.obs.empty()
	) -> Observable:
		return obs.using(resource_factory, observable_factory)

## Creates an Observable that emits a tuple of the latest items emitted from
## the sources.
func WithLatestFrom(sources : Array[Observable]) -> Observable:
	var _sources : Array[Observable] = sources.duplicate()
	var parent = _sources.pop_front()
	return obs.with_latest_from(parent, _sources)

## Creates an Observable that emits tuples of the items with same order emitted 
## by all sources.
func Zip(sources : Array[Observable]) -> Observable:
	return obs.zip(sources)

## Creates an observale that repeats a given value for a certain amount.
func RepeatValue(value, repeat_count = null) -> Observable:
	return obs.repeat_value(value, repeat_count)

## Merges an array of observable sequences into a new observable sequence.
func Merge(sources : Array[Observable]) -> Observable:
	return obs.merge(sources)

func ToAsync(fun : Callable, scheduler : SchedulerBase = null) -> Callable:
		return obs.to_async(fun, scheduler)

## Creates an observable which emits an item every time a time period has passed.
func Interval(period_sec : float, scheduler : SchedulerBase = null) -> Observable:
	return obs.interval(period_sec, scheduler)

## Creates an observable timer
func StartTimespan(timespan_sec : float) -> Observable:
	return obs.timer(timespan_sec, false)

## Creates an observable periodic timer
func StartPeriodicTimer(period_sec : float) -> Observable:
	return obs.timer(period_sec, false, period_sec)

## Creates an observable periodic timer which starts after a timespan has passed
func StartPeriodicTimerAfterTimespan(timespan_sec : float, period_sec : float) -> Observable:
	return obs.timer(timespan_sec, false, period_sec)

## Creates an observable timer
func ScheduleDatetime(datetime_sec : float) -> Observable:
	return obs.timer(datetime_sec, true)

## Creates an observable periodic timer which starts at a given timestamp.
func StartPeriodicTimerAtDatetime(datetime_sec : float, period_sec : float) -> Observable:
	return obs.timer(datetime_sec, true, period_sec)

## Creates an observable from a Godot Signal
func FromGodotSignal(conn : Object, signal_name : String) -> Observable:
	var n_args : int = -1
	for sig in conn.get_signal_list():
		if sig["name"] == signal_name:
			n_args = sig["args"].size()
			break
	return gd.from_godot_signal(conn, signal_name, n_args)

## Adds user signal to node and creates an observable from it.
func CreateGodotUserSignal(conn : Object, signal_name : String, n_args : int, args : Array = []) -> Observable:
	if conn.has_signal(signal_name):
		return FromGodotSignal(conn, signal_name)
	var _args : Array = []
	if not args.is_empty() and n_args <= 0:
		_args = args
	else:
		for i in range(n_args):
			_args.append({"name":"arg" + str(i), "type":TYPE_MAX})
	conn.add_user_signal(signal_name, _args)
	return FromGodotSignal(conn, signal_name)

## Emits items from [method Node._process].
func OnProcessAsObservable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 0)

## Emits items from [method Node._physics_process].
func OnPhysicsProcessAsObservable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 1)

## Emits items from [method Node._input].
func OnInputAsObservable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 2)

## Emits items from [method Node._shortcut_input].
func OnShortcutInputAsObservable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 3)

## Emits items from [method Node._unhandled_input].
func OnUnhandledInputAsObservable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 4)

## Emits items from [method Node._unhandled_key_input].
func OnUnhandledKeyInputAsObservable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 5)

## Tranforms an input action into an observable sequence emiting items on check.
func FromGodotInputAction(input_action : String, checks : Observable) -> Observable:
	return gd.from_godot_input_action(input_action, checks)
