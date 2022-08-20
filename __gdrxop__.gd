class_name __GDRx_Op__
## Provides access to [Observable] operators.
##
## Bridge between operator implementations and [__GDRx_Singleton__]

var _RefCount_ = load("res://reactivex/operators/connectable/_refcount.gd")

var _All_ = load("res://reactivex/operators/_all.gd")
var _Amb_ = load("res://reactivex/operators/_amb.gd")
var _AsObservable_ = load("res://reactivex/operators/_asobservable.gd")
var _Average_ = load("res://reactivex/operators/_average.gd")
var _Buffer_ = load("res://reactivex/operators/_buffer.gd")
var _BufferWithTime_ = load("res://reactivex/operators/_bufferwithtime.gd")
var _BufferWithTimeOrCount_ = load("res://reactivex/operators/_bufferwithtimeorcount.gd")
var _Catch_ = load("res://reactivex/operators/_catch.gd")
var _CombineLatest_ = load("res://reactivex/operators/_combinelatest.gd")
var _Concat_ = load("res://reactivex/operators/_concat.gd")
var _Contains_ = load("res://reactivex/operators/_contains.gd")
var _Count_ = load("res://reactivex/operators/_count.gd")
var _Debounce_ = load("res://reactivex/operators/_debounce.gd")
var _DefaultIfEmpty_ = load("res://reactivex/operators/_defaultifempty.gd")
var _Delay_ = load("res://reactivex/operators/_delay.gd")
var _DelaySubscription_ = load("res://reactivex/operators/_delaysubscription.gd")
var _DelayWithMapper_ = load("res://reactivex/operators/_delaywithmapper.gd")
var _Dematerialize_ = load("res://reactivex/operators/_dematerialize.gd")
var _Distinct_ = load("res://reactivex/operators/_distinct.gd")
var _DistinctUntilChanged_ = load("res://reactivex/operators/_distinctuntilchanged.gd")
var _Do_ = load("res://reactivex/operators/_do.gd")
var _DoWhile_ = load("res://reactivex/operators/_dowhile.gd")
var _ElementAtOrDefault_ = load("res://reactivex/operators/_elementatordefault.gd")
var _Exclusive_ = load("res://reactivex/operators/_exclusive.gd")
var _Expand_ = load("res://reactivex/operators/_expand.gd")
var _Filter_ = load("res://reactivex/operators/_filter.gd")
var _FinallyAction_ = load("res://reactivex/operators/_finallyaction.gd")
var _Find_ = load("res://reactivex/operators/_find.gd")
var _First_ = load("res://reactivex/operators/_first.gd")
var _FirstOrDefault_ = load("res://reactivex/operators/_firstordefault.gd")
var _FlatMap_ = load("res://reactivex/operators/_flatmap.gd")
var _ForkJoin_ = load("res://reactivex/operators/_forkjoin.gd")
var _GroupBy_ = load("res://reactivex/operators/_groupby.gd")
var _GroupByUntil_ = load("res://reactivex/operators/_groupbyuntil.gd")
var _GroupJoin_ = load("res://reactivex/operators/_groupjoin.gd")
var _IgnoreElements_ = load("res://reactivex/operators/_ignoreelements.gd")
var _IsEmpty_ = load("res://reactivex/operators/_isempty.gd")
var _Join_ = load("res://reactivex/operators/_join.gd")
var _Last_ = load("res://reactivex/operators/_last.gd")
var _LastOrDefault_ = load("res://reactivex/operators/_lastordefault.gd")
var _Map_ = load("res://reactivex/operators/_map.gd")
var _Materialize_ = load("res://reactivex/operators/_materialize.gd")
var _Merge_ = load("res://reactivex/operators/_merge.gd")
var _Max_ = load("res://reactivex/operators/_max.gd")
var _MaxBy_ = load("res://reactivex/operators/_maxby.gd")
var _Min_ = load("res://reactivex/operators/_min.gd")
var _MinBy_ = load("res://reactivex/operators/_minby.gd")
var _Multicast_ = load("res://reactivex/operators/_multicast.gd")
var _ObserveOn_ = load("res://reactivex/operators/_observeon.gd")
var _OnErrorResumeNext_ = load("res://reactivex/operators/_onerrorresumenext.gd")
var _Pairwise_ = load("res://reactivex/operators/_pairwise.gd")
var _Partition_ = load("res://reactivex/operators/_partition.gd")
var _Pluck_ = load("res://reactivex/operators/_pluck.gd")
var _Publish_ = load("res://reactivex/operators/_publish.gd")
var _PublishValue_ = load("res://reactivex/operators/_publishvalue.gd")
var _Reduce_ = load("res://reactivex/operators/_reduce.gd")
var _Repeat_ = load("res://reactivex/operators/_repeat.gd")
var _Replay_ = load("res://reactivex/operators/_replay.gd")
var _Retry_ = load("res://reactivex/operators/_retry.gd")
var _Sample_ = load("res://reactivex/operators/_sample.gd")
var _Scan_ = load("res://reactivex/operators/_scan.gd")
var _SequenceEqual_ = load("res://reactivex/operators/_sequenceequal.gd")
var _Single_ = load("res://reactivex/operators/_single.gd")
var _SingleOrDefault_ = load("res://reactivex/operators/_singleordefault.gd")
var _Skip_ = load("res://reactivex/operators/_skip.gd")
var _SkipLast_ = load("res://reactivex/operators/_skiplast.gd")
var _SkipLastWithTime_ = load("res://reactivex/operators/_skiplastwithtime.gd")
var _SkipUntil_ = load("res://reactivex/operators/_skipuntil.gd")
var _SkipUntilWithTime_ = load("res://reactivex/operators/_skipuntilwithtime.gd")
var _SkipWhile_ = load("res://reactivex/operators/_skipwhile.gd")
var _SkipWithTime_ = load("res://reactivex/operators/_skipwithtime.gd")
var _Slice_ = load("res://reactivex/operators/_slice.gd")
var _Some_ = load("res://reactivex/operators/_some.gd")
var _StartWith_ = load("res://reactivex/operators/_startswith.gd")
var _SubscribeOn_ = load("res://reactivex/operators/_subscribeon.gd")
var _Sum_ = load("res://reactivex/operators/_sum.gd")
var _SwitchLatest_ = load("res://reactivex/operators/_switchlatest.gd")
var _TakeLast_ = load("res://reactivex/operators/_takelast.gd")
var _Take_ = load("res://reactivex/operators/_take.gd")
var _TakeLastBuffer_ = load("res://reactivex/operators/_takelastbuffer.gd")
var _TakeLastWithTime_ = load("res://reactivex/operators/_takelastwithtime.gd")
var _TakeUntil_ = load("res://reactivex/operators/_takeuntil.gd")
var _TakeUntilWithTime_ = load("res://reactivex/operators/_takeuntilwithtime.gd")
var _TakeWhile_ = load("res://reactivex/operators/_takewhile.gd")
var _TakeWithTime_ = load("res://reactivex/operators/_takewithtime.gd")
var _ThrottleFirst_ = load("res://reactivex/operators/_throttlefirst.gd")
var _TimeInterval_ = load("res://reactivex/operators/_timeinterval.gd")
var _Timeout_ = load("res://reactivex/operators/_timeout.gd")
var _TimeoutWithMapper_ = load("res://reactivex/operators/_timeoutwithmapper.gd")
var _TimeStamp_ = load("res://reactivex/operators/_timestamp.gd")
var _ToDict_ = load("res://reactivex/operators/_todict.gd")
var _ToIterable_ = load("res://reactivex/operators/_toiterable.gd")
var _ToList_ = load("res://reactivex/operators/_tolist.gd")
var _ToSet_ = load("res://reactivex/operators/_toset.gd")
var _WhileDo_ = load("res://reactivex/operators/_whiledo.gd")
var _Window_ = load("res://reactivex/operators/_window.gd")
var _WindowWithCount_ = load("res://reactivex/operators/_windowwithcount.gd")
var _WindowWithTime_ = load("res://reactivex/operators/_windowwithtime.gd")
var _WindowWithTimeOrCount_ = load("res://reactivex/operators/_windowwithtimeorcount.gd")
var _WithLatestFrom_ = load("res://reactivex/operators/_withlatestfrom.gd")
var _Zip_ = load("res://reactivex/operators/_zip.gd")

func ref_count() -> Callable:
	return _RefCount_.ref_count_()

func all(predicate : Callable) -> Callable:
	return _All_.all_(predicate)

func amb(right_source : Observable) -> Callable:
	return _Amb_.amb_(right_source)

func as_observable() -> Callable:
	return _AsObservable_.as_observable_()

func average(key_mapper = null) -> Callable:
	return _Average_.average_(key_mapper)

func buffer(boundaries : Observable) -> Callable:
	return _Buffer_.buffer_(boundaries)

func buffer_when(closing_mapper : Callable) -> Callable:
	return _Buffer_.buffer_when_(closing_mapper)

func buffer_toggle(openings : Observable, closing_mapper : Callable) -> Callable:
	return _Buffer_.buffer_toggle_(openings, closing_mapper)

func buffer_with_count(count : int, skip = null) -> Callable:
	return _Buffer_.buffer_with_count_(count, skip)

func buffer_with_time(timespan : float, timeshift = null, scheduler : SchedulerBase = null) -> Callable:
	return _BufferWithTime_.buffer_with_time_(timespan, timeshift, scheduler)

func buffer_with_time_or_count(timespan : float, count : int, scheduler : SchedulerBase = null) -> Callable:
	return _BufferWithTimeOrCount_.buffer_with_time_or_count_(timespan, count, scheduler)

func catch_handler(source : Observable, handler : Callable) -> Observable:
	return _Catch_.catch_handler(source, handler)

func catch(handler) -> Callable:
	return _Catch_.catch_(handler)

func combine_latest(others : Array[Observable]) -> Callable:
	return _CombineLatest_.combine_latest_(others)

func concat(sources : Array[Observable]) -> Callable:
	return _Concat_.concat_(sources)

func contains(value, comparer = GDRx.basic.default_comparer) -> Callable:
	return _Contains_.contains_(value, comparer)

func count(predicate = null) -> Callable:
	return _Count_.count_(predicate)

func debounce(duetime : float, scheduler : SchedulerBase = null) -> Callable:
	return _Debounce_.debounce_(duetime, scheduler)

func throttle_with_mapper(throttle_duration_mapper : Callable) -> Callable:
	return _Debounce_.throttle_with_mapper_(throttle_duration_mapper)

func default_if_empty(default_value = null) -> Callable:
	return _DefaultIfEmpty_.default_if_empty_(default_value)

func observable_delay_timespan(source : Observable, duetime : float, scheduler : SchedulerBase = null) -> Observable:
	return _Delay_.observable_delay_timespan(source, duetime, scheduler)

func delay(duetime : float, scheduler : SchedulerBase = null) -> Callable:
	return _Delay_.delay_(duetime, scheduler)

func delay_subscription(duetime : float, time_absolute : bool = false, scheduler : SchedulerBase = null) -> Callable:
	return _DelaySubscription_.delay_subscription_(duetime, time_absolute, scheduler)

func delay_with_mapper(subscription_delay = null, delay_duration_mapper = null) -> Callable:
	return _DelayWithMapper_.delay_with_mapper_(subscription_delay, delay_duration_mapper)

func dematerialize() -> Callable:
	return _Dematerialize_.dematerialize()

func distinct(key_mapper : Callable = GDRx.basic.identity, comparer : Callable = GDRx.basic.default_comparer) -> Callable:
	return _Distinct_.distinct_(key_mapper, comparer)

func distinct_until_changed(key_mapper : Callable = GDRx.basic.identity, comparer : Callable = GDRx.basic.default_comparer) -> Callable:
	return _DistinctUntilChanged_.distinct_until_changed_(key_mapper, comparer)

func do_action(on_next = null, on_error = null, on_completed = null) -> Callable:
	return _Do_.do_action_(on_next, on_error, on_completed)

func do(observer : ObserverBase) -> Callable:
	return _Do_.do_(observer)

func do_after_next(source : Observable, after_next : Callable) -> Observable:
	return _Do_.do_after_next(source, after_next)

func do_on_subscribe(source : Observable, on_subscribe : Callable) -> Observable:
	return _Do_.do_on_subscribe(source, on_subscribe)

func do_on_dispose(source : Observable, on_dispose : Callable) -> Observable:
	return _Do_.do_on_dispose(source, on_dispose)

func do_on_terminate(source : Observable, on_terminate : Callable) -> Observable:
	return _Do_.do_on_terminate(source, on_terminate)

func do_after_terminate(source : Observable, after_terminate : Callable) -> Observable:
	return _Do_.do_after_terminate(source, after_terminate)

func do_finally(finally_action : Callable) -> Callable:
	return _Do_.do_finally(finally_action)

func do_while(condition : Callable) -> Callable:
	return _DoWhile_.do_while_(condition)

func element_at_or_default(index : int, has_default : bool = false, default_value = GDRx.util.GetNotSet()) -> Callable:
	return _ElementAtOrDefault_.element_at_or_default_(index, has_default, default_value)

func exclusive() -> Callable:
	return _Exclusive_.exclusive_()

func expand(mapper : Callable) -> Callable:
	return _Expand_.expand_(mapper)

func filter(predicate : Callable = func(x): return true) -> Callable:
	return _Filter_.filter_(predicate)

func filter_indexed(predicate : Callable = func(x, index): return true) -> Callable:
	return _Filter_.filter_indexed_(predicate)

func finally_action(action : Callable) -> Callable:
	return _FinallyAction_.finally_action_(action)

func find_value(predicate : Callable, yield_index : bool) -> Callable:
	return _Find_.find_value_(predicate, yield_index)

func first(predicate = null) -> Callable:
	return _First_.first_(predicate)

func first_or_default_async(has_default : bool = false, default_value = null) -> Callable:
	return _FirstOrDefault_.first_or_default_async_(has_default, default_value)

func first_or_default(predicate = null, default_value = null) -> Callable:
	return _FirstOrDefault_.first_or_default_(predicate, default_value)

func flat_map(mapper = null) -> Callable:
	return _FlatMap_.flat_map_(mapper)

func flat_map_indexed(mapper_indexed = null) -> Callable:
	return _FlatMap_.flat_map_indexed_(mapper_indexed)

func flat_map_latest(mapper = null) -> Callable:
	return _FlatMap_.flat_map_latest_(mapper)

func fork_join(args : Array[Observable]) -> Callable:
	return _ForkJoin_.fork_join(args)
	
func group_by(key_mapper : Callable, element_mapper = null, subject_mapper = null) -> Callable:
	return _GroupBy_.group_by_(key_mapper, element_mapper, subject_mapper)

func group_by_until(key_mapper : Callable, duration_mapper : Callable, element_mapper = null, subject_mapper = null) -> Callable:
	return _GroupByUntil_.group_by_until_(key_mapper, duration_mapper, element_mapper, subject_mapper)

func group_join(right : Observable, left_duration_mapper : Callable, right_duration_mapper : Callable) -> Callable:
	return _GroupJoin_.group_join_(right, left_duration_mapper, right_duration_mapper)

func ignore_elements() -> Callable:
	return _IgnoreElements_.ignore_elements_()

func is_empty() -> Callable:
	return _IsEmpty_.is_empty_()

func join(right : Observable, left_duration_mapper : Callable, right_duration_mapper : Callable) -> Callable:
	return _Join_.join_(right, left_duration_mapper, right_duration_mapper)

func last(predicate = null) -> Callable:
	return _Last_.last_(predicate)

func last_or_default_async(source : Observable, has_default : bool = false, default_value = null) -> Observable:
	return _LastOrDefault_.last_or_default_async(source, has_default, default_value)

func last_or_default(default_value = null, predicate = null) -> Callable:
	return _LastOrDefault_.last_or_default_(default_value, predicate)

func map(mapper : Callable = GDRx.util.identity) -> Callable:
	return _Map_.map_(mapper)

func map_indexed(mapper_indexed : Callable = func(value, idx : int): return value) -> Callable:
	return _Map_.map_indexed_(mapper_indexed)

func materialize() -> Callable:
	return _Materialize_.materialize_()

func max(comparer = null) -> Callable:
	return _Max_.max_(comparer)

func max_by(key_mapper : Callable, comparer = null) -> Callable:
	return _MaxBy_.max_by_(key_mapper, comparer)

func merge(sources : Array[Observable], max_concorrent : int = -1) -> Callable:
	return _Merge_.merge_(sources, max_concorrent)

func merge_all() -> Callable:
	return _Merge_.merge_all_()

func min(comparer = null) -> Callable:
	return _Min_.min_(comparer)

func extrema_by(source : Observable, key_mapper : Callable, comparer : Callable) -> Observable:
	return _MinBy_.extrema_by(source, key_mapper, comparer)

func min_by(key_mapper : Callable, comparer = null) -> Callable:
	return _MinBy_.min_by_(key_mapper, comparer)

func multicast(subject : SubjectBase = null, subject_factory = null, mapper = null) -> Callable:
	return _Multicast_.multicast_(subject, subject_factory, mapper)

func observe_on(scheduler : SchedulerBase) -> Callable:
	return _ObserveOn_.observe_on_(scheduler)

func on_error_resume_next(second : Observable) -> Callable:
	return _OnErrorResumeNext_.on_error_resume_next_(second)

func pairwise() -> Callable:
	return _Pairwise_.pairwise_()

func partition(predicate : Callable = func(x): return true) -> Callable:
	return _Partition_.partition_(predicate)

func partition_indexed(predicate_indexed : Callable = func(x, i : int): return true) -> Callable:
	return _Partition_.partition_indexed_(predicate_indexed)

func pluck(key) -> Callable:
	return _Pluck_.pluck_(key)

func pluck_attr(prop : String) -> Callable:
	return _Pluck_.pluck_attr_(prop)

func publish(mapper = null) -> Callable:
	return _Publish_.publish_(mapper)

func share() -> Callable:
	return _Publish_.share_()

func publish_value(initial_value, mapper = null) -> Callable:
	return _PublishValue_.publish_value_(initial_value, mapper)

func reduce(accumulator : Callable, seed = GDRx.util.GetNotSet()) -> Callable:
	return _Reduce_.reduce_(accumulator, seed)

func repeat(repeat_count = null) -> Callable:
	return _Repeat_.repeat_(repeat_count)

func replay(mapper = null, buffer_size = null, window = null, scheduler : SchedulerBase = null) -> Callable:
	return _Replay_.replay_(mapper, buffer_size, window, scheduler)

func retry(retry_count : int = -1) -> Callable:
	return _Retry_.retry_(retry_count)

func sample_observable(source : Observable, sampler : Observable) -> Observable:
	return _Sample_.sample_observable(source, sampler)

func sample(sampler : Observable, sampler_time : float = NAN, scheduler : SchedulerBase = null) -> Callable:
	return _Sample_.sample_(sampler, sampler_time, scheduler)

func scan(accumulator : Callable, seed = GDRx.util.GetNotSet()) -> Callable:
	return _Scan_.scan_(accumulator, seed)

func sequence_equal(second : Observable, comparer  = null, second_it : IterableBase = null) -> Callable:
	return _SequenceEqual_.sequence_equal_(second, comparer, second_it)

func single(predicate = null) -> Callable:
	return _Single_.single_(predicate)

func single_or_default_async(has_default : bool = false, default_value = null) -> Callable:
	return _SingleOrDefault_.single_or_default_async_(has_default, default_value)

func single_or_default(predicate = null, default_value = null) -> Callable:
	return _SingleOrDefault_.single_or_default_(predicate, default_value)

func skip(count : int) -> Callable:
	return _Skip_.skip_(count)

func skip_last(count : int) -> Callable:
	return _SkipLast_.skip_last_(count)

func skip_last_with_time(duration : float, scheduler : SchedulerBase = null) -> Callable:
	return _SkipLastWithTime_.skip_last_with_time_(duration, scheduler)

func skip_until(other : Observable) -> Callable:
	return _SkipUntil_.skip_until_(other)

func skip_until_with_time(start_time : float, time_absolute : bool = false, scheduler : SchedulerBase = null) -> Callable:
	return _SkipUntilWithTime_.skip_until_with_time_(start_time, time_absolute, scheduler)

func skip_while(predicate : Callable) -> Callable:
	return _SkipWhile_.skip_while_(predicate)

func skip_while_indexed(predicate : Callable) -> Callable:
	return _SkipWhile_.skip_while_indexed_(predicate)

func skip_with_time(duration : float, scheduler : SchedulerBase = null) -> Callable:
	return _SkipWithTime_.skip_with_time_(duration, scheduler)

func slice(start : int = 0, stop : int = GDRx.util.MAX_SIZE, step : int = 1) -> Callable:
	return _Slice_.slice_(start, stop, step)

func some(predicate = null) -> Callable:
	return _Some_.some_(predicate)

func start_with(args : Array) -> Callable:
	return _StartWith_.start_with_(args)

func subscribe_on(scheduler : SchedulerBase) -> Callable:
	return _SubscribeOn_.subscribe_on_(scheduler)

func sum(key_mapper = null) -> Callable:
	return _Sum_.sum_(key_mapper)

func switch_latest() -> Callable:
	return _SwitchLatest_.switch_latest_()

func take(count : int) -> Callable:
	return _Take_.take_(count)

func take_last(count : int) -> Callable:
	return _TakeLast_.take_last_(count)

func take_last_buffer(count : int) -> Callable:
	return _TakeLastBuffer_.take_last_buffer_(count)

func take_last_with_time(duration : float, scheduler : SchedulerBase = null) -> Callable:
	return _TakeLastWithTime_.take_last_with_time_(duration, scheduler)

func take_until(other : Observable) -> Callable:
	return _TakeUntil_.take_until_(other)

func take_until_with_time(end_time : float, absolute : bool = false, scheduler : SchedulerBase = null) -> Callable:
	return _TakeUntilWithTime_.take_until_with_time_(end_time, absolute, scheduler)

func take_while(predicate : Callable = func(value) -> bool: return true, inclusive : bool = false) -> Callable:
	return _TakeWhile_.take_while_(predicate, inclusive)

func take_while_indexed(predicate : Callable = func(value, index) -> bool: return true, inclusive : bool = false) -> Callable:
	return _TakeWhile_.take_while_indexed_(predicate, inclusive)

func take_with_time(duration : float, scheduler : SchedulerBase = null) -> Callable:
	return _TakeWithTime_.take_with_time_(duration, scheduler) 

func throttle_first(window_duration : float, scheduler : SchedulerBase = null) -> Callable:
	return _ThrottleFirst_.throttle_first_(window_duration, scheduler)

func time_interval(scheduler : SchedulerBase = null) -> Callable:
	return _TimeInterval_.time_interval_(scheduler)

func timeout(duetime : float, absolute : bool = false, other : Observable = null, scheduler : SchedulerBase = null) -> Callable:
	return _Timeout_.timeout_(duetime, absolute, other, scheduler)

func timeout_with_mapper(first_timeout : Observable = null, timeout_duration_mapper : Callable = func(__) -> Observable: return GDRx.obs.never(), other : Observable = null) -> Callable:
	return _TimeoutWithMapper_.timeout_with_mapper_(first_timeout, timeout_duration_mapper, other)

func timestamp(scheduler : SchedulerBase = null) -> Callable:
	return _TimeStamp_.timestamp_(scheduler)

func to_dict(key_mapper : Callable, element_mapper : Callable = func(v): return v) -> Callable:
	return _ToDict_.to_dict_(key_mapper, element_mapper)

func to_iterable() -> Callable:
	return _ToIterable_.to_iterable_()

func to_list() -> Callable:
	return _ToList_.to_list_()

func to_set() -> Callable:
	return _ToSet_.to_set_()

func while_do(condition : Callable = func(): return true) -> Callable:
	return _WhileDo_.while_do_(condition)

func window_toggle(openings : Observable, closing_mapper : Callable) -> Callable:
	return _Window_.window_toggle_(openings, closing_mapper)

func window(boundaries : Observable) -> Callable:
	return _Window_.window_(boundaries)

func window_when(closing_mapper : Callable) -> Callable:
	return _Window_.window_when_(closing_mapper)

func window_with_count(count : int, skip = null) -> Callable:
	return _WindowWithCount_.window_with_count_(count, skip)

func window_with_time(timespan : float, timeshift = null, scheduler : SchedulerBase = null) -> Callable:
	return _WindowWithTime_.window_with_time_(timespan, timeshift, scheduler)

func window_with_time_or_count(timespan : float, count : int, scheduler : SchedulerBase = null) -> Callable:
	return _WindowWithTimeOrCount_.window_with_time_or_count_(timespan, count, scheduler)

func with_latest_from(sources : Array[Observable]) -> Callable:
	return _WithLatestFrom_.with_latest_from_(sources)

func zip(args : Array[Observable]) -> Callable:
	return _Zip_.zip_(args)

func zip_with_iterable(seq : IterableBase) -> Callable:
	return _Zip_.zip_with_iterable_(seq)
