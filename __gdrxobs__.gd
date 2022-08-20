class_name __GDRx_Obs__
## Provides access to [Observable] constructor.
##
## Bridge between [Observable] constructor implementations and [__GDRx_Singleton__]

var _Amb_ = load("res://reactivex/observable/amb.gd")
var _Case_ = load("res://reactivex/observable/case.gd")
var _Catch_ = load("res://reactivex/observable/catch.gd")
var _CombineLatest_ = load("res://reactivex/observable/combinelatest.gd")
var _Concat_ = load("res://reactivex/observable/concat.gd")
var _Defer_ = load("res://reactivex/observable/defer.gd")
var _Empty_ = load("res://reactivex/observable/empty.gd")
var _ForkJoin_ = load("res://reactivex/observable/forkjoin.gd")
var _FromCallback_ = load("res://reactivex/observable/fromcallback.gd")
var _FromIterable_ = load("res://reactivex/observable/fromiterable.gd")
var _Generate_ = load("res://reactivex/observable/generate.gd")
var _GenerateWithRealtiveTime_ = load("res://reactivex/observable/generatewithrelativetime.gd")
var _IfThen_ = load("res://reactivex/observable/ifthen.gd")
var _Interval_ = load("res://reactivex/observable/interval.gd")
var _Merge_ = load("res://reactivex/observable/merge.gd")
var _Never_ = load("res://reactivex/observable/never.gd")
var _OnErrorResumeNext_ = load("res://reactivex/observable/onerrorresumenext.gd")
var _Range_ = load("res://reactivex/observable/range.gd")
var _Repeat_ = load("res://reactivex/observable/repeat.gd")
var _ReturnValue_ = load("res://reactivex/observable/returnvalue.gd")
var _Throw_ = load("res://reactivex/observable/throw.gd")
var _Timer_ = load("res://reactivex/observable/timer.gd")
var _ToAsync_ = load("res://reactivex/observable/toasync.gd")
var _Using_ = load("res://reactivex/observable/using.gd")
var _WithLatestFrom_ = load("res://reactivex/observable/withlatestfrom.gd")
var _Zip_ = load("res://reactivex/observable/zip.gd")

## See: [b]res://reactivex/observable/amb.gd[/b]
func amb(sources : Array[Observable]) -> Observable:
	return _Amb_.amb_(sources)

## See: [b]res://reactivex/observable/case.gd[/b]
func case(mapper : Callable, sources : Dictionary, default_source : Observable = null) -> Observable:
	return _Case_.case_(mapper, sources, default_source)

## See: [b]res://reactivex/observable/catch.gd[/b]
func catch_with_iterable(sources : IterableBase) -> Observable:
	return _Catch_.catch_with_iterable_(sources)

## See: [b]res://reactivex/observable/combinelatest.gd[/b]
func combine_latest(sources : Array[Observable]) -> Observable:
	return _CombineLatest_.combine_latest_(sources)

## See: [b]res://reactivex/observable/concat.gd[/b]
func concat_with_iterable(sources : IterableBase) -> Observable:
	return _Concat_.concat_with_iterable_(sources)

## See: [b]res://reactivex/observable/defer.gd[/b]
func defer(factory : Callable = func(scheduler : SchedulerBase) -> Observable: return null) -> Observable:
	return _Defer_.defer_(factory)

## See: [b]res://reactivex/observable/empty.gd[/b]
func empty(scheduler : SchedulerBase = null) -> Observable:
	return _Empty_.empty_(scheduler)

## See: [b]res://reactivex/observable/forkjoin.gd[/b]
func fork_join(sources : Array[Observable]) -> Observable:
	return _ForkJoin_.fork_join_(sources)

## See: [b]res://reactivex/observable/fromcallback.gd[/b]
func from_callback(fun : Callable = func(args : Array, cb : Callable): return, mapper : Callable = func(args): return args) -> Callable:
	return _FromCallback_.from_callback_(fun, mapper)

## See: [b]res://reactivex/observable/fromiterable.gd[/b]
func from_iterable(iterable : IterableBase, scheduler : SchedulerBase = null) -> Observable:
	return _FromIterable_.from_iterable_(iterable, scheduler)

## See: [b]res://reactivex/observable/generate.gd[/b]
func generate(initial_state, condition : Callable = func(state) -> bool: return true, iterate : Callable = func(state): return state) -> Observable:
	return _Generate_.generate_(initial_state, condition, iterate)

## See: [b]res://reactivex/observable/generatewithrealtivetime.gd[/b]
func generate_with_relative_time(initial_state, condition : Callable = func(state) -> bool: return true, iterate : Callable = func(state): return state, time_mapper : Callable = func(state) -> float: return 1.0) -> Observable:
	return _GenerateWithRealtiveTime_.generate_with_relative_time_(initial_state, condition, iterate, time_mapper)

## See: [b]res://reactivex/observable/ifthen.gd[/b]
func if_then(then_source : Observable, else_source : Observable = null, condition : Callable = func() -> bool: return true) -> Observable:
	return _IfThen_.if_then_(then_source, else_source, condition)

## See: [b]res://reactivex/observable/interval.gd[/b]
func interval(period : float, scheduler : SchedulerBase = null) -> ObservableBase:
	return _Interval_.interval_(period, scheduler)

## See: [b]res://reactivex/observable/merge.gd[/b]
func merge(sources : Array[Observable]) -> Observable:
	return _Merge_.merge_(sources)

## See: [b]res://reactivex/observable/never.gd[/b]
func never() -> Observable:
	return _Never_.never_()

## See: [b]res://reactivex/observable/onerrorresumenext.gd[/b]
func on_error_resume_next(sources : Array) -> Observable:
	return _OnErrorResumeNext_.on_error_resume_next_(sources)

## See: [b]res://reactivex/observable/range.gd[/b]
func range(start : int, stop = null, step = null, scheduler : SchedulerBase = null) -> Observable:
	return _Range_.range_(start, stop, step, scheduler)

## See: [b]res://reactivex/observable/repeat.gd[/b]
func repeat_value(value, repeat_count = null) -> Observable:
	return _Repeat_.repeat_value_(value, repeat_count)

## See: [b]res://reactivex/observable/returnvalue.gd[/b]
func return_value(value, scheduler : SchedulerBase = null) -> Observable:
	return _ReturnValue_.return_value_(value, scheduler)

## See: [b]res://reactivex/observable/returnvalue.gd[/b]
func return_value_from_callback(supplier : Callable, scheduler : SchedulerBase = null) -> Observable:
	return _ReturnValue_.from_callback_(supplier, scheduler)

## See: [b]res://reactivex/observable/throw.gd[/b]
func throw(err, scheduler : SchedulerBase = null) -> Observable:
	return _Throw_.throw_(err, scheduler)

## See: [b]res://reactivex/observable/timer.gd[/b]
func timer(duetime : float, time_absolute : bool, period = null, scheduler : SchedulerBase = null) -> Observable:
	return _Timer_.timer_(duetime, time_absolute, period, scheduler)

## See: [b]res://reactivex/observable/toasync.gd[/b]
func to_async(fun : Callable, scheduler : SchedulerBase = null) -> Callable:
	return _ToAsync_.to_async_(fun, scheduler)

## See: [b]res://reactivex/observable/using.gd[/b]
func using(resource_factory : Callable, observable_factory : Callable,) -> Observable:
	return _Using_.using_(resource_factory, observable_factory)

## See: [b]res://reactivex/observable/withlatestfrom.gd[/b]
func with_latest_from(parent : Observable, sources : Array[Observable]) -> Observable:
	return _WithLatestFrom_.with_latest_from_(parent, sources)

## See: [b]res://reactivex/observable/zip.gd[/b]
func zip(sources : Array[Observable]) -> Observable:
	return _Zip_.zip_(sources)
