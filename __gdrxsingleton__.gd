extends Node
class_name __GDRx_Singleton__

### ======================================================================= ###
#   Init script database
### ======================================================================= ###
var __init__ : __GDRx_Init__ = __GDRx_Init__.new()
## Observables ##
var obs : __GDRx_Obs__ = __GDRx_Obs__.new()
## Operators ##
var op : __GDRx_Op__ = __GDRx_Op__.new()
## Engine Backend ##
var gd : __GDRx_Engine__ = __GDRx_Engine__.new()
## Notifications ##
var OnNext = __init__.NotificationOnNext_
var OnError = __init__.NotificationOnError_
var OnCompleted = __init__.NotificationOnCompleted_
## Internals ##
var heap = __init__.Heap_.new()
var err = __init__.Error_.new()
var basic = __init__.Basic_.new()
var concur = __init__.Concurrency_.new()
var util = __init__.Util_.new()
## Pipe ##
var pipe = __init__.Pipe_.new()

### ======================================================================= ###
#   Scheduler Singletons
### ======================================================================= ###
var ImmediateScheduler_ : ImmediateScheduler = ImmediateScheduler.new("GDRx")
var TimeoutScheduler_ : TimeoutScheduler = TimeoutScheduler.new("GDRx")
var GodotSignalScheduler_ : GodotSignalScheduler = GodotSignalScheduler.new("GDRx")

var CurrentThreadScheduler_global_ : WeakRefDictionary = WeakRefDictionary.new()
var CurrentThreadScheduler_local_ = CurrentThreadScheduler._Local.new()

### ======================================================================= ###
#   Observable Constructors
### ======================================================================= ###
func Create(subscribe : Callable = func(observer : ObserverBase, scheduler : SchedulerBase = null) -> DisposableBase: return Disposable.new()) -> Observable:
	return Observable.new(subscribe)
func Empty(scheduler : SchedulerBase = null) -> Observable:
	return obs.empty(scheduler)
func Never(scheduler : SchedulerBase = null) -> Observable:
	return obs.never()
func Throw(err, scheduler : SchedulerBase = null) -> Observable:
	return obs.throw(err, scheduler)
func ReturnValue(value, scheduler : SchedulerBase = null) -> Observable:
	return obs.return_value(value, scheduler)
func FromCallback(supplier : Callable, scheduler : SchedulerBase = null) -> Observable:
	return obs.return_value_from_callback(supplier, scheduler)
func WinnerOf(observables : Array[Observable]) -> Observable:
	return obs.amb(observables)
func BuildDeferred(factory : Callable = func(scheduler : SchedulerBase) -> Observable: return null) -> Observable:
	return obs.defer(factory)
func SwitchCase(mapper : Callable, sources : Dictionary, default_source : Observable = null) -> Observable:
	return obs.case(mapper, sources, default_source)
func CatchAndContinueWith(sources : Array[Observable]) -> Observable:
	return obs.catch_with_iterable(GDRx.util.Iter(sources))
func CombineLatestOf(sources : Array[Observable]) -> Observable:
	if sources.is_empty():
		return Empty()
	if sources.size() == 1:
		return sources[0]
	return obs.combine_latest(sources)
func ConcatStreams(sources : Array[Observable]) -> Observable:
	return obs.concat_with_iterable(GDRx.util.Iter(sources))
func ConcatStreamsWithIterable(sources : IterableBase) -> Observable:
	return obs.concat_with_iterable(sources)
func ForkJoin(sources : Array[Observable]) -> Observable:
	return obs.fork_join(sources)
func BuildFromCallback(fun : Callable = func(args : Array, cb : Callable): return, mapper : Callable = func(args): return args) -> Callable:
	return obs.from_callback(fun, mapper)
func FromArray(array : Array) -> Observable:
	return obs.from_iterable(GDRx.util.Iter(array))
func FromIterable(iterable : IterableBase) -> Observable:
	return obs.from_iterable(iterable)
func GenerateFrom(initial_state, condition : Callable, iterate : Callable) -> Observable:
	return obs.generate(initial_state, condition, iterate)
func GenerateWithRealtiveTime(initial_state, condition : Callable, iterate : Callable, time_mapper : Callable) -> Observable:
	return obs.generate_with_relative_time(initial_state, condition, iterate, time_mapper)
func IfThenElse(then_source : Observable, else_source : Observable, condition : Callable = func() -> bool: return true) -> Observable:
	return obs.if_then(then_source, else_source, condition)
func IfThen(then_source : Observable, condition : Callable = func() -> bool: return true) -> Observable:
	return obs.if_then(then_source, null, condition)
func ResumeAfterTerminationWith(sources : Array) -> Observable:
	return obs.on_error_resume_next(sources)
func FromRange(start : int, stop = null, step = null, scheduler : SchedulerBase = null) -> Observable:
	return obs.range(start, stop, step, scheduler)
func BuildUsing(
		resource_factory : Callable = func() -> DisposableBase: return null, 
		observable_factory : Callable = func(disp : DisposableBase) -> DisposableBase: return GDRx.obs.empty()
	) -> Observable:
		return obs.using(resource_factory, observable_factory)
func WithLatestFrom(sources : Array[Observable]) -> Observable:
	var _sources : Array[Observable] = sources.duplicate()
	var parent = _sources.pop_front()
	return obs.with_latest_from(parent, _sources)
func Zip(sources : Array[Observable]) -> Observable:
	return obs.zip(sources)
func RepeatValue(value, repeat_count = null) -> Observable:
	return obs.repeat_value(value, repeat_count)
func Merge(sources : Array[Observable]) -> Observable:
	return obs.merge(sources)
func ToAsync(fun : Callable, scheduler : SchedulerBase = null) -> Callable:
		return obs.to_async(fun, scheduler)
## Timers ##
func Interval(period_sec : float, scheduler : SchedulerBase = null) -> Observable:
	return obs.interval(period_sec, scheduler)
func StartTimespan(timespan_sec : float) -> Observable:
	return obs.timer(timespan_sec, false)
func StartPeriodicTimer(period_sec : float) -> Observable:
	return obs.timer(period_sec, false, period_sec)
func StartPeriodicTimerAfterTimespan(timespan_sec : float, period_sec : float) -> Observable:
	return obs.timer(timespan_sec, false, period_sec)
func ScheduleDatetime(datetime_sec : float) -> Observable:
	return obs.timer(datetime_sec, true)
func StartPeriodicTimerAtDatetime(datetime_sec : float, period_sec : float) -> Observable:
	return obs.timer(datetime_sec, true, period_sec)
## Godot ##
func FromGodotSignal(conn, signal_name : String) -> Observable:
	var n_args : int = -1
	for sig in conn.get_signal_list():
		if sig["name"] == signal_name:
			n_args = sig["args"].size()
			break
	return gd.from_godot_signal(conn.get(signal_name) as Signal, n_args)
func GodotSignalAsObservable(sig : Signal, n_args) -> Observable:
	return gd.from_godot_signal(sig, n_args)
func CreateGodotUserSignal(conn : Node, signal_name : String, n_args : int, args : Array = []) -> Observable:
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
func OnProcessAsObservable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 0)
func OnPhysicsProcessAsObservable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 1)
func OnInputAsObservable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 2)
func OnShortcutInputAsObservable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 3)
func OnUnhandledInputAsObservable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 4)
func OnUnhandledKeyInputAsObservable(conn : Node) -> Observable:
	return gd.from_godot_node_lifecycle_event(conn, 5)
func FromGodotInputAction(input_action : String, checks : Observable) -> Observable:
	return gd.from_godot_input_action(input_action, checks)
