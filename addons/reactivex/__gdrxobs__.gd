class_name __GDRx_Obs__
## Provides access to [Observable] constructor.
##
## Bridge between [Observable] constructor implementations and [__GDRx_Singleton__]

var _Amb_ = load("res://addons/reactivex/observable/amb.gd")
var _Case_ = load("res://addons/reactivex/observable/case.gd")
var _Catch_ = load("res://addons/reactivex/observable/catch.gd")
var _CombineLatest_ = load("res://addons/reactivex/observable/combinelatest.gd")
var _Concat_ = load("res://addons/reactivex/observable/concat.gd")
var _Defer_ = load("res://addons/reactivex/observable/defer.gd")
var _Empty_ = load("res://addons/reactivex/observable/empty.gd")
var _ForkJoin_ = load("res://addons/reactivex/observable/forkjoin.gd")
var _FromCallback_ = load("res://addons/reactivex/observable/fromcallback.gd")
var _FromIterable_ = load("res://addons/reactivex/observable/fromiterable.gd")
var _Generate_ = load("res://addons/reactivex/observable/generate.gd")
var _GenerateWithRealtiveTime_ = load("res://addons/reactivex/observable/generatewithrelativetime.gd")
var _IfThen_ = load("res://addons/reactivex/observable/ifthen.gd")
var _Interval_ = load("res://addons/reactivex/observable/interval.gd")
var _Merge_ = load("res://addons/reactivex/observable/merge.gd")
var _Never_ = load("res://addons/reactivex/observable/never.gd")
var _OnErrorResumeNext_ = load("res://addons/reactivex/observable/onerrorresumenext.gd")
var _Range_ = load("res://addons/reactivex/observable/range.gd")
var _Repeat_ = load("res://addons/reactivex/observable/repeat.gd")
var _ReturnValue_ = load("res://addons/reactivex/observable/returnvalue.gd")
var _Throw_ = load("res://addons/reactivex/observable/throw.gd")
var _Timer_ = load("res://addons/reactivex/observable/timer.gd")
var _ToAsync_ = load("res://addons/reactivex/observable/toasync.gd")
var _Using_ = load("res://addons/reactivex/observable/using.gd")
var _WithLatestFrom_ = load("res://addons/reactivex/observable/withlatestfrom.gd")
var _Zip_ = load("res://addons/reactivex/observable/zip.gd")

## See: [b]res://addons/reactivex/observable/amb.gd[/b]
func amb(sources) -> Observable:
	return _Amb_.amb_(sources)

## See: [b]res://addons/reactivex/observable/case.gd[/b]
func case(mapper : Callable, sources : Dictionary, default_source : Observable = null) -> Observable:
	return _Case_.case_(mapper, sources, default_source)

## See: [b]res://addons/reactivex/observable/catch.gd[/b]
func catch_with_iterable(sources : IterableBase) -> Observable:
	return _Catch_.catch_with_iterable_(sources)

## See: [b]res://addons/reactivex/observable/combinelatest.gd[/b]
func combine_latest(sources) -> Observable:
	return _CombineLatest_.combine_latest_(sources)

## See: [b]res://addons/reactivex/observable/concat.gd[/b]
func concat_with_iterable(sources : IterableBase) -> Observable:
	return _Concat_.concat_with_iterable_(sources)

## See: [b]res://addons/reactivex/observable/defer.gd[/b]
func defer(factory : Callable = GDRx.basic.default_factory) -> Observable:
	return _Defer_.defer_(factory)

## See: [b]res://addons/reactivex/observable/empty.gd[/b]
func empty(scheduler : SchedulerBase = null) -> Observable:
	return _Empty_.empty_(scheduler)

## See: [b]res://addons/reactivex/observable/forkjoin.gd[/b]
func fork_join(sources) -> Observable:
	return _ForkJoin_.fork_join_(sources)

## See: [b]res://addons/reactivex/observable/fromcallback.gd[/b]
func from_callback(fun : Callable = func(_args : Array, _cb : Callable): return, mapper = null) -> Callable:
	return _FromCallback_.from_callback_(fun, mapper)

## See: [b]res://addons/reactivex/observable/fromiterable.gd[/b]
func from_iterable(iterable : IterableBase, scheduler : SchedulerBase = null) -> Observable:
	return _FromIterable_.from_iterable_(iterable, scheduler)

## See: [b]res://addons/reactivex/observable/generate.gd[/b]
func generate(initial_state, condition : Callable = GDRx.basic.default_condition, iterate : Callable = GDRx.basic.identity) -> Observable:
	return _Generate_.generate_(initial_state, condition, iterate)

## See: [b]res://addons/reactivex/observable/generatewithrealtivetime.gd[/b]
func generate_with_relative_time(initial_state, condition : Callable = GDRx.basic.default_condition, iterate : Callable = GDRx.basic.identity, time_mapper : Callable = func(_state) -> float: return 1.0) -> Observable:
	return _GenerateWithRealtiveTime_.generate_with_relative_time_(initial_state, condition, iterate, time_mapper)

## See: [b]res://addons/reactivex/observable/ifthen.gd[/b]
func if_then(condition : Callable = GDRx.basic.default_condition, then_source : Observable = null, else_source : Observable = null) -> Observable:
	return _IfThen_.if_then_(condition, then_source, else_source)

## See: [b]res://addons/reactivex/observable/interval.gd[/b]
func interval(period : float, scheduler : SchedulerBase = null) -> ObservableBase:
	return _Interval_.interval_(period, scheduler)

## See: [b]res://addons/reactivex/observable/merge.gd[/b]
func merge(sources) -> Observable:
	return _Merge_.merge_(sources)

## See: [b]res://addons/reactivex/observable/never.gd[/b]
func never() -> Observable:
	return _Never_.never_()

## See: [b]res://addons/reactivex/observable/onerrorresumenext.gd[/b]
func on_error_resume_next(sources) -> Observable:
	return _OnErrorResumeNext_.on_error_resume_next_(sources)

## See: [b]res://addons/reactivex/observable/range.gd[/b]
@warning_ignore("shadowed_global_identifier")
func range(start : int, stop = null, step = null, scheduler : SchedulerBase = null) -> Observable:
	return _Range_.range_(start, stop, step, scheduler)

## See: [b]res://addons/reactivex/observable/repeat.gd[/b]
func repeat_value(value, repeat_count = null) -> Observable:
	return _Repeat_.repeat_value_(value, repeat_count)

## See: [b]res://addons/reactivex/observable/returnvalue.gd[/b]
func return_value(value, scheduler : SchedulerBase = null) -> Observable:
	return _ReturnValue_.return_value_(value, scheduler)

## See: [b]res://addons/reactivex/observable/returnvalue.gd[/b]
func from_callable(supplier : Callable, scheduler : SchedulerBase = null) -> Observable:
	return _ReturnValue_.from_callable_(supplier, scheduler)

## See: [b]res://addons/reactivex/observable/throw.gd[/b]
func throw(err, scheduler : SchedulerBase = null) -> Observable:
	return _Throw_.throw_(err, scheduler)

## See: [b]res://addons/reactivex/observable/timer.gd[/b]
func timer(duetime : float, time_absolute : bool, period = null, scheduler : SchedulerBase = null) -> Observable:
	return _Timer_.timer_(duetime, time_absolute, period, scheduler)

## See: [b]res://addons/reactivex/observable/toasync.gd[/b]
func to_async(fun : Callable, scheduler : SchedulerBase = null) -> Callable:
	return _ToAsync_.to_async_(fun, scheduler)

## See: [b]res://addons/reactivex/observable/using.gd[/b]
func using(resource_factory : Callable, observable_factory : Callable,) -> Observable:
	return _Using_.using_(resource_factory, observable_factory)

## See: [b]res://addons/reactivex/observable/withlatestfrom.gd[/b]
func with_latest_from(parent : Observable, sources) -> Observable:
	return _WithLatestFrom_.with_latest_from_(parent, sources)

## See: [b]res://addons/reactivex/observable/zip.gd[/b]
func zip(sources) -> Observable:
	return _Zip_.zip_(sources)
