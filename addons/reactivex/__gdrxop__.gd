class_name __GDRx_Op__
## Provides access to [Observable] operators.
##
## Bridge between operator implementations and [__GDRx_Singleton__]

var _RefCount_ = load("res://addons/reactivex/operators/connectable/_refcount.gd")

var _All_ = load("res://addons/reactivex/operators/_all.gd")
var _Amb_ = load("res://addons/reactivex/operators/_amb.gd")
var _AsObservable_ = load("res://addons/reactivex/operators/_asobservable.gd")
var _Average_ = load("res://addons/reactivex/operators/_average.gd")
var _Buffer_ = load("res://addons/reactivex/operators/_buffer.gd")
var _BufferWithTime_ = load("res://addons/reactivex/operators/_bufferwithtime.gd")
var _BufferWithTimeOrCount_ = load("res://addons/reactivex/operators/_bufferwithtimeorcount.gd")
var _Catch_ = load("res://addons/reactivex/operators/_catch.gd")
var _CombineLatest_ = load("res://addons/reactivex/operators/_combinelatest.gd")
var _Concat_ = load("res://addons/reactivex/operators/_concat.gd")
var _Contains_ = load("res://addons/reactivex/operators/_contains.gd")
var _Count_ = load("res://addons/reactivex/operators/_count.gd")
var _Debounce_ = load("res://addons/reactivex/operators/_debounce.gd")
var _DefaultIfEmpty_ = load("res://addons/reactivex/operators/_defaultifempty.gd")
var _Delay_ = load("res://addons/reactivex/operators/_delay.gd")
var _DelaySubscription_ = load("res://addons/reactivex/operators/_delaysubscription.gd")
var _DelayWithMapper_ = load("res://addons/reactivex/operators/_delaywithmapper.gd")
var _Dematerialize_ = load("res://addons/reactivex/operators/_dematerialize.gd")
var _Distinct_ = load("res://addons/reactivex/operators/_distinct.gd")
var _DistinctUntilChanged_ = load("res://addons/reactivex/operators/_distinctuntilchanged.gd")
var _Do_ = load("res://addons/reactivex/operators/_do.gd")
var _DoWhile_ = load("res://addons/reactivex/operators/_dowhile.gd")
var _ElementAtOrDefault_ = load("res://addons/reactivex/operators/_elementatordefault.gd")
var _Exclusive_ = load("res://addons/reactivex/operators/_exclusive.gd")
var _Expand_ = load("res://addons/reactivex/operators/_expand.gd")
var _Filter_ = load("res://addons/reactivex/operators/_filter.gd")
var _FinallyAction_ = load("res://addons/reactivex/operators/_finallyaction.gd")
var _Find_ = load("res://addons/reactivex/operators/_find.gd")
var _First_ = load("res://addons/reactivex/operators/_first.gd")
var _FirstOrDefault_ = load("res://addons/reactivex/operators/_firstordefault.gd")
var _FlatMap_ = load("res://addons/reactivex/operators/_flatmap.gd")
var _ForkJoin_ = load("res://addons/reactivex/operators/_forkjoin.gd")
var _GroupBy_ = load("res://addons/reactivex/operators/_groupby.gd")
var _GroupByUntil_ = load("res://addons/reactivex/operators/_groupbyuntil.gd")
var _GroupJoin_ = load("res://addons/reactivex/operators/_groupjoin.gd")
var _IgnoreElements_ = load("res://addons/reactivex/operators/_ignoreelements.gd")
var _IsEmpty_ = load("res://addons/reactivex/operators/_isempty.gd")
var _Join_ = load("res://addons/reactivex/operators/_join.gd")
var _Last_ = load("res://addons/reactivex/operators/_last.gd")
var _LastOrDefault_ = load("res://addons/reactivex/operators/_lastordefault.gd")
var _Map_ = load("res://addons/reactivex/operators/_map.gd")
var _Materialize_ = load("res://addons/reactivex/operators/_materialize.gd")
var _Merge_ = load("res://addons/reactivex/operators/_merge.gd")
var _Max_ = load("res://addons/reactivex/operators/_max.gd")
var _MaxBy_ = load("res://addons/reactivex/operators/_maxby.gd")
var _Min_ = load("res://addons/reactivex/operators/_min.gd")
var _MinBy_ = load("res://addons/reactivex/operators/_minby.gd")
var _Multicast_ = load("res://addons/reactivex/operators/_multicast.gd")
var _ObserveOn_ = load("res://addons/reactivex/operators/_observeon.gd")
var _OfType_ = load("res://addons/reactivex/operators/_oftype.gd")
var _OnErrorResumeNext_ = load("res://addons/reactivex/operators/_onerrorresumenext.gd")
var _Pairwise_ = load("res://addons/reactivex/operators/_pairwise.gd")
var _Partition_ = load("res://addons/reactivex/operators/_partition.gd")
var _Pluck_ = load("res://addons/reactivex/operators/_pluck.gd")
var _Publish_ = load("res://addons/reactivex/operators/_publish.gd")
var _PublishValue_ = load("res://addons/reactivex/operators/_publishvalue.gd")
var _Reduce_ = load("res://addons/reactivex/operators/_reduce.gd")
var _Repeat_ = load("res://addons/reactivex/operators/_repeat.gd")
var _Replay_ = load("res://addons/reactivex/operators/_replay.gd")
var _Retry_ = load("res://addons/reactivex/operators/_retry.gd")
var _Sample_ = load("res://addons/reactivex/operators/_sample.gd")
var _Scan_ = load("res://addons/reactivex/operators/_scan.gd")
var _SequenceEqual_ = load("res://addons/reactivex/operators/_sequenceequal.gd")
var _Single_ = load("res://addons/reactivex/operators/_single.gd")
var _SingleOrDefault_ = load("res://addons/reactivex/operators/_singleordefault.gd")
var _Skip_ = load("res://addons/reactivex/operators/_skip.gd")
var _SkipLast_ = load("res://addons/reactivex/operators/_skiplast.gd")
var _SkipLastWithTime_ = load("res://addons/reactivex/operators/_skiplastwithtime.gd")
var _SkipUntil_ = load("res://addons/reactivex/operators/_skipuntil.gd")
var _SkipUntilWithTime_ = load("res://addons/reactivex/operators/_skipuntilwithtime.gd")
var _SkipWhile_ = load("res://addons/reactivex/operators/_skipwhile.gd")
var _SkipWithTime_ = load("res://addons/reactivex/operators/_skipwithtime.gd")
var _Slice_ = load("res://addons/reactivex/operators/_slice.gd")
var _Some_ = load("res://addons/reactivex/operators/_some.gd")
var _StartWith_ = load("res://addons/reactivex/operators/_startswith.gd")
var _SubscribeOn_ = load("res://addons/reactivex/operators/_subscribeon.gd")
var _Sum_ = load("res://addons/reactivex/operators/_sum.gd")
var _SwitchLatest_ = load("res://addons/reactivex/operators/_switchlatest.gd")
var _TakeLast_ = load("res://addons/reactivex/operators/_takelast.gd")
var _Take_ = load("res://addons/reactivex/operators/_take.gd")
var _TakeLastBuffer_ = load("res://addons/reactivex/operators/_takelastbuffer.gd")
var _TakeLastWithTime_ = load("res://addons/reactivex/operators/_takelastwithtime.gd")
var _TakeUntil_ = load("res://addons/reactivex/operators/_takeuntil.gd")
var _TakeUntilWithTime_ = load("res://addons/reactivex/operators/_takeuntilwithtime.gd")
var _TakeWhile_ = load("res://addons/reactivex/operators/_takewhile.gd")
var _TakeWithTime_ = load("res://addons/reactivex/operators/_takewithtime.gd")
var _ThrottleFirst_ = load("res://addons/reactivex/operators/_throttlefirst.gd")
var _TimeInterval_ = load("res://addons/reactivex/operators/_timeinterval.gd")
var _Timeout_ = load("res://addons/reactivex/operators/_timeout.gd")
var _TimeoutWithMapper_ = load("res://addons/reactivex/operators/_timeoutwithmapper.gd")
var _TimeStamp_ = load("res://addons/reactivex/operators/_timestamp.gd")
var _ToDict_ = load("res://addons/reactivex/operators/_todict.gd")
var _ToIterable_ = load("res://addons/reactivex/operators/_toiterable.gd")
var _ToList_ = load("res://addons/reactivex/operators/_tolist.gd")
var _ToSet_ = load("res://addons/reactivex/operators/_toset.gd")
var _WhileDo_ = load("res://addons/reactivex/operators/_whiledo.gd")
var _Window_ = load("res://addons/reactivex/operators/_window.gd")
var _WindowWithCount_ = load("res://addons/reactivex/operators/_windowwithcount.gd")
var _WindowWithTime_ = load("res://addons/reactivex/operators/_windowwithtime.gd")
var _WindowWithTimeOrCount_ = load("res://addons/reactivex/operators/_windowwithtimeorcount.gd")
var _WithLatestFrom_ = load("res://addons/reactivex/operators/_withlatestfrom.gd")
var _Zip_ = load("res://addons/reactivex/operators/_zip.gd")

## See: [b]res://addons/reactivex/operators/connectable/_refcount.gd[/b]
func ref_count() -> Callable:
	return _RefCount_.ref_count_()

## See: [b]res://addons/reactivex/operators/_all.gd[/b]
func all(predicate : Callable) -> Callable:
	return _All_.all_(predicate)

## See: [b]res://addons/reactivex/operators/_amb.gd[/b]
func amb(right_source : Observable) -> Callable:
	return _Amb_.amb_(right_source)

## See: [b]res://addons/reactivex/operators/_asobservable.gd[/b]
func as_observable() -> Callable:
	return _AsObservable_.as_observable_()

## See: [b]res://addons/reactivex/operators/_average.gd[/b]
func average(key_mapper = null) -> Callable:
	return _Average_.average_(key_mapper)

## See: [b]res://addons/reactivex/operators/_buffer.gd[/b]
func buffer(boundaries : Observable) -> Callable:
	return _Buffer_.buffer_(boundaries)

## See: [b]res://addons/reactivex/operators/_buffer.gd[/b]
func buffer_when(closing_mapper : Callable) -> Callable:
	return _Buffer_.buffer_when_(closing_mapper)

## See: [b]res://addons/reactivex/operators/_buffer.gd[/b]
func buffer_toggle(openings : Observable, closing_mapper : Callable) -> Callable:
	return _Buffer_.buffer_toggle_(openings, closing_mapper)

## See: [b]res://addons/reactivex/operators/_buffer.gd[/b]
func buffer_with_count(count_ : int, skip_ = null) -> Callable:
	return _Buffer_.buffer_with_count_(count_, skip_)

## See: [b]res://addons/reactivex/operators/_bufferwithtime.gd[/b]
func buffer_with_time(timespan : float, timeshift = null, scheduler : SchedulerBase = null) -> Callable:
	return _BufferWithTime_.buffer_with_time_(timespan, timeshift, scheduler)

## See: [b]res://addons/reactivex/operators/_bufferwithtimeourcount.gd[/b]
func buffer_with_time_or_count(timespan : float, count_ : int, scheduler : SchedulerBase = null) -> Callable:
	return _BufferWithTimeOrCount_.buffer_with_time_or_count_(timespan, count_, scheduler)

## See: [b]res://addons/reactivex/operators/_catch.gd[/b]
func catch_handler(source : Observable, handler : Callable) -> Observable:
	return _Catch_.catch_handler(source, handler)

## See: [b]res://addons/reactivex/operators/_catch.gd[/b]
func catch(handler) -> Callable:
	return _Catch_.catch_(handler)

## See: [b]res://addons/reactivex/operators/_combinelatest.gd[/b]
func combine_latest(others) -> Callable:
	return _CombineLatest_.combine_latest_(others)

## See: [b]res://addons/reactivex/operators/_concat.gd[/b]
func concat(sources) -> Callable:
	return _Concat_.concat_(sources)

## See: [b]res://addons/reactivex/operators/_contains.gd[/b]
func contains(value, comparer = GDRx.basic.default_comparer) -> Callable:
	return _Contains_.contains_(value, comparer)

## See: [b]res://addons/reactivex/operators/_count.gd[/b]
func count(predicate = null) -> Callable:
	return _Count_.count_(predicate)

## See: [b]res://addons/reactivex/operators/_debounce.gd[/b]
func debounce(duetime : float, scheduler : SchedulerBase = null) -> Callable:
	return _Debounce_.debounce_(duetime, scheduler)

## See: [b]res://addons/reactivex/operators/_debounce.gd[/b]
func throttle_with_mapper(throttle_duration_mapper : Callable) -> Callable:
	return _Debounce_.throttle_with_mapper_(throttle_duration_mapper)

## See: [b]res://addons/reactivex/operators/_defaultifempty.gd[/b]
func default_if_empty(default_value = null) -> Callable:
	return _DefaultIfEmpty_.default_if_empty_(default_value)

## See: [b]res://addons/reactivex/operators/_delay.gd[/b]
func observable_delay_timespan(source : Observable, duetime : float, scheduler : SchedulerBase = null) -> Observable:
	return _Delay_.observable_delay_timespan(source, duetime, scheduler)

## See: [b]res://addons/reactivex/operators/_delay.gd[/b]
func delay(duetime : float, scheduler : SchedulerBase = null) -> Callable:
	return _Delay_.delay_(duetime, scheduler)

## See: [b]res://addons/reactivex/operators/_delaysubscription.gd[/b]
func delay_subscription(duetime : float, time_absolute : bool = false, scheduler : SchedulerBase = null) -> Callable:
	return _DelaySubscription_.delay_subscription_(duetime, time_absolute, scheduler)

## See: [b]res://addons/reactivex/operators/_delaywithmapper.gd[/b]
func delay_with_mapper(subscription_delay = null, delay_duration_mapper = null) -> Callable:
	return _DelayWithMapper_.delay_with_mapper_(subscription_delay, delay_duration_mapper)

## See: [b]res://addons/reactivex/operators/_dematerialize.gd[/b]
func dematerialize() -> Callable:
	return _Dematerialize_.dematerialize()

## See: [b]res://addons/reactivex/operators/_distinct.gd[/b]
func distinct(key_mapper : Callable = GDRx.basic.identity, comparer : Callable = GDRx.basic.default_comparer) -> Callable:
	return _Distinct_.distinct_(key_mapper, comparer)

## See: [b]res://addons/reactivex/operators/_distinctuntilchanged.gd[/b]
func distinct_until_changed(key_mapper : Callable = GDRx.basic.identity, comparer : Callable = GDRx.basic.default_comparer) -> Callable:
	return _DistinctUntilChanged_.distinct_until_changed_(key_mapper, comparer)

## See: [b]res://addons/reactivex/operators/_do.gd[/b]
func do_action(on_next = null, on_error = null, on_completed = null) -> Callable:
	return _Do_.do_action_(on_next, on_error, on_completed)

## See: [b]res://addons/reactivex/operators/_do.gd[/b]
func do(observer : ObserverBase) -> Callable:
	return _Do_.do_(observer)

## See: [b]res://addons/reactivex/operators/_do.gd[/b]
func do_after_next(source : Observable, after_next : Callable) -> Observable:
	return _Do_.do_after_next(source, after_next)

## See: [b]res://addons/reactivex/operators/_do.gd[/b]
func do_on_subscribe(source : Observable, on_subscribe : Callable) -> Observable:
	return _Do_.do_on_subscribe(source, on_subscribe)

## See: [b]res://addons/reactivex/operators/_do.gd[/b]
func do_on_dispose(source : Observable, on_dispose : Callable) -> Observable:
	return _Do_.do_on_dispose(source, on_dispose)

## See: [b]res://addons/reactivex/operators/_do.gd[/b]
func do_on_terminate(source : Observable, on_terminate : Callable) -> Observable:
	return _Do_.do_on_terminate(source, on_terminate)

## See: [b]res://addons/reactivex/operators/_do.gd[/b]
func do_after_terminate(source : Observable, after_terminate : Callable) -> Observable:
	return _Do_.do_after_terminate(source, after_terminate)

## See: [b]res://addons/reactivex/operators/_do.gd[/b]
func do_finally(finally_action_ : Callable) -> Callable:
	return _Do_.do_finally(finally_action_)

## See: [b]res://addons/reactivex/operators/_dowhile.gd[/b]
func do_while(condition : Callable) -> Callable:
	return _DoWhile_.do_while_(condition)

## See: [b]res://addons/reactivex/operators/_elementordefault.gd[/b]
func element_at_or_default(index : int, has_default : bool = false, default_value = GDRx.util.GetNotSet()) -> Callable:
	return _ElementAtOrDefault_.element_at_or_default_(index, has_default, default_value)

## See: [b]res://addons/reactivex/operators/_exclusive.gd[/b]
func exclusive() -> Callable:
	return _Exclusive_.exclusive_()

## See: [b]res://addons/reactivex/operators/_expand.gd[/b]
func expand(mapper : Callable) -> Callable:
	return _Expand_.expand_(mapper)

## See: [b]res://addons/reactivex/operators/_filter.gd[/b]
func filter(predicate : Callable = GDRx.basic.default_condition) -> Callable:
	return _Filter_.filter_(predicate)

## See: [b]res://addons/reactivex/operators/_filter.gd[/b]
func filter_indexed(predicate : Callable = GDRx.basic.default_condition) -> Callable:
	return _Filter_.filter_indexed_(predicate)

## See: [b]res://addons/reactivex/operators/_finallyaction.gd[/b]
func finally_action(action : Callable) -> Callable:
	return _FinallyAction_.finally_action_(action)

## See: [b]res://addons/reactivex/operators/_find.gd[/b]
func find_value(predicate : Callable, yield_index : bool) -> Callable:
	return _Find_.find_value_(predicate, yield_index)

## See: [b]res://addons/reactivex/operators/_first.gd[/b]
func first(predicate = null) -> Callable:
	return _First_.first_(predicate)

## See: [b]res://addons/reactivex/operators/_firstordefault.gd[/b]
func first_or_default_async(has_default : bool = false, default_value = null) -> Callable:
	return _FirstOrDefault_.first_or_default_async_(has_default, default_value)

## See: [b]res://addons/reactivex/operators/_firstordefault.gd[/b]
func first_or_default(predicate = null, default_value = null) -> Callable:
	return _FirstOrDefault_.first_or_default_(predicate, default_value)

## See: [b]res://addons/reactivex/operators/_flatmap.gd[/b]
func flat_map(mapper = null) -> Callable:
	return _FlatMap_.flat_map_(mapper)

## See: [b]res://addons/reactivex/operators/_flatmap.gd[/b]
func flat_map_indexed(mapper_indexed = null) -> Callable:
	return _FlatMap_.flat_map_indexed_(mapper_indexed)

## See: [b]res://addons/reactivex/operators/_flatmap.gd[/b]
func flat_map_latest(mapper = null) -> Callable:
	return _FlatMap_.flat_map_latest_(mapper)

## See: [b]res://addons/reactivex/operators/_forkjoin.gd[/b]
func fork_join(args) -> Callable:
	return _ForkJoin_.fork_join_(args)

## See: [b]res://addons/reactivex/operators/_groupby.gd[/b]
func group_by(key_mapper : Callable, element_mapper = null, subject_mapper = null) -> Callable:
	return _GroupBy_.group_by_(key_mapper, element_mapper, subject_mapper)

## See: [b]res://addons/reactivex/operators/_groupbyuntil.gd[/b]
func group_by_until(key_mapper : Callable, duration_mapper : Callable, element_mapper = null, subject_mapper = null) -> Callable:
	return _GroupByUntil_.group_by_until_(key_mapper, duration_mapper, element_mapper, subject_mapper)

## See: [b]res://addons/reactivex/operators/_groupjoin.gd[/b]
func group_join(right : Observable, left_duration_mapper : Callable, right_duration_mapper : Callable) -> Callable:
	return _GroupJoin_.group_join_(right, left_duration_mapper, right_duration_mapper)

## See: [b]res://addons/reactivex/operators/_ignoreelements.gd[/b]
func ignore_elements() -> Callable:
	return _IgnoreElements_.ignore_elements_()

## See: [b]res://addons/reactivex/operators/_isempty.gd[/b]
func is_empty() -> Callable:
	return _IsEmpty_.is_empty_()

## See: [b]res://addons/reactivex/operators/_join.gd[/b]
func join(right : Observable, left_duration_mapper : Callable, right_duration_mapper : Callable) -> Callable:
	return _Join_.join_(right, left_duration_mapper, right_duration_mapper)

## See: [b]res://addons/reactivex/operators/_last.gd[/b]
func last(predicate = null) -> Callable:
	return _Last_.last_(predicate)

## See: [b]res://addons/reactivex/operators/_lastordefault.gd[/b]
func last_or_default_async(source : Observable, has_default : bool = false, default_value = null) -> Observable:
	return _LastOrDefault_.last_or_default_async(source, has_default, default_value)

## See: [b]res://addons/reactivex/operators/_lastordefault.gd[/b]
func last_or_default(default_value = null, predicate = null) -> Callable:
	return _LastOrDefault_.last_or_default_(default_value, predicate)

## See: [b]res://addons/reactivex/operators/_map.gd[/b]
func map(mapper : Callable = GDRx.basic.identity) -> Callable:
	return _Map_.map_(mapper)

## See: [b]res://addons/reactivex/operators/_map.gd[/b]
func map_indexed(mapper_indexed : Callable = GDRx.basic.identity) -> Callable:
	return _Map_.map_indexed_(mapper_indexed)

## See: [b]res://addons/reactivex/operators/_materialize.gd[/b]
func materialize() -> Callable:
	return _Materialize_.materialize_()

## See: [b]res://addons/reactivex/operators/_max.gd[/b]
@warning_ignore("shadowed_global_identifier")
func max(comparer = null) -> Callable:
	return _Max_.max_(comparer)

## See: [b]res://addons/reactivex/operators/_maxby.gd[/b]
func max_by(key_mapper : Callable, comparer = null) -> Callable:
	return _MaxBy_.max_by_(key_mapper, comparer)

## See: [b]res://addons/reactivex/operators/_merge.gd[/b]
func merge(sources, max_concorrent : int = -1) -> Callable:
	return _Merge_.merge_(sources, max_concorrent)

## See: [b]res://addons/reactivex/operators/_merge.gd[/b]
func merge_all() -> Callable:
	return _Merge_.merge_all_()

## See: [b]res://addons/reactivex/operators/_min.gd[/b]
@warning_ignore("shadowed_global_identifier")
func min(comparer = null) -> Callable:
	return _Min_.min_(comparer)

## See: [b]res://addons/reactivex/operators/_minby.gd[/b]
func extrema_by(source : Observable, key_mapper : Callable, comparer : Callable) -> Observable:
	return _MinBy_.extrema_by(source, key_mapper, comparer)

## See: [b]res://addons/reactivex/operators/_minby.gd[/b]
func min_by(key_mapper : Callable, comparer = null) -> Callable:
	return _MinBy_.min_by_(key_mapper, comparer)

## See: [b]res://addons/reactivex/operators/_multicast.gd[/b]
func multicast(subject : SubjectBase = null, subject_factory = null, mapper = null) -> Callable:
	return _Multicast_.multicast_(subject, subject_factory, mapper)

## See: [b]res://addons/reactivex/operators/_observeon.gd[/b]
func observe_on(scheduler : SchedulerBase) -> Callable:
	return _ObserveOn_.observe_on_(scheduler)

## See: [b]res://addons/reactivex/operators/_oftype.gd[/b]
func oftype(type, push_err : bool = true, type_equality : Callable = GDRx.basic.default_type_equality) -> Callable:
	return _OfType_.oftype_(type, push_err, type_equality)

## See: [b]res://addons/reactivex/operators/_onerrorresumenext.gd[/b]
func on_error_resume_next(second : Observable) -> Callable:
	return _OnErrorResumeNext_.on_error_resume_next_(second)

## See: [b]res://addons/reactivex/operators/_pairwise.gd[/b]
func pairwise() -> Callable:
	return _Pairwise_.pairwise_()

## See: [b]res://addons/reactivex/operators/_partiton.gd[/b]
func partition(predicate : Callable = GDRx.basic.default_condition) -> Callable:
	return _Partition_.partition_(predicate)

## See: [b]res://addons/reactivex/operators/_partition.gd[/b]
func partition_indexed(predicate_indexed : Callable = GDRx.basic.default_condition) -> Callable:
	return _Partition_.partition_indexed_(predicate_indexed)

## See: [b]res://addons/reactivex/operators/_pluck.gd[/b]
func pluck(key) -> Callable:
	return _Pluck_.pluck_(key)

## See: [b]res://addons/reactivex/operators/_pluck.gd[/b]
func pluck_attr(prop : String) -> Callable:
	return _Pluck_.pluck_attr_(prop)

## See: [b]res://addons/reactivex/operators/_publish.gd[/b]
func publish(mapper = null) -> Callable:
	return _Publish_.publish_(mapper)

## See: [b]res://addons/reactivex/operators/_publish.gd[/b]
func share() -> Callable:
	return _Publish_.share_()

## See: [b]res://addons/reactivex/operators/_publishvalue.gd[/b]
func publish_value(initial_value, mapper = null) -> Callable:
	return _PublishValue_.publish_value_(initial_value, mapper)

## See: [b]res://addons/reactivex/operators/_reduce.gd[/b]
func reduce(accumulator : Callable, seed_ = GDRx.util.GetNotSet()) -> Callable:
	return _Reduce_.reduce_(accumulator, seed_)

## See: [b]res://addons/reactivex/operators/_repeat.gd[/b]
func repeat(repeat_count = null) -> Callable:
	return _Repeat_.repeat_(repeat_count)

## See: [b]res://addons/reactivex/operators/_replay.gd[/b]
func replay(mapper = null, buffer_size = null, window_ = null, scheduler : SchedulerBase = null) -> Callable:
	return _Replay_.replay_(mapper, buffer_size, window_, scheduler)

## See: [b]res://addons/reactivex/operators/_retry.gd[/b]
func retry(retry_count : int = -1) -> Callable:
	return _Retry_.retry_(retry_count)

## See: [b]res://addons/reactivex/operators/_sample.gd[/b]
func sample_observable(source : Observable, sampler : Observable) -> Observable:
	return _Sample_.sample_observable(source, sampler)

## See: [b]res://addons/reactivex/operators/_sample.gd[/b]
func sample(sampler : Observable, sampler_time : float = NAN, scheduler : SchedulerBase = null) -> Callable:
	return _Sample_.sample_(sampler, sampler_time, scheduler)

## See: [b]res://addons/reactivex/operators/_scan.gd[/b]
func scan(accumulator : Callable, seed_ = GDRx.util.GetNotSet()) -> Callable:
	return _Scan_.scan_(accumulator, seed_)

## See: [b]res://addons/reactivex/operators/_sequenceequal.gd[/b]
func sequence_equal(second, comparer  = null, second_it : IterableBase = null) -> Callable:
	return _SequenceEqual_.sequence_equal_(second, comparer, second_it)

## See: [b]res://addons/reactivex/operators/_single.gd[/b]
func single(predicate = null) -> Callable:
	return _Single_.single_(predicate)

## See: [b]res://addons/reactivex/operators/_singleordefault.gd[/b]
func single_or_default_async(has_default : bool = false, default_value = null) -> Callable:
	return _SingleOrDefault_.single_or_default_async_(has_default, default_value)

## See: [b]res://addons/reactivex/operators/_singleordefault.gd[/b]
func single_or_default(predicate = null, default_value = null) -> Callable:
	return _SingleOrDefault_.single_or_default_(predicate, default_value)

## See: [b]res://addons/reactivex/operators/_skip.gd[/b]
func skip(count_ : int) -> Callable:
	return _Skip_.skip_(count_)

## See: [b]res://addons/reactivex/operators/_skiplast.gd[/b]
func skip_last(count_ : int) -> Callable:
	return _SkipLast_.skip_last_(count_)

## See: [b]res://addons/reactivex/operators/_skiplastwithtime.gd[/b]
func skip_last_with_time(duration : float, scheduler : SchedulerBase = null) -> Callable:
	return _SkipLastWithTime_.skip_last_with_time_(duration, scheduler)

## See: [b]res://addons/reactivex/operators/_skipuntil.gd[/b]
func skip_until(other : Observable) -> Callable:
	return _SkipUntil_.skip_until_(other)

## See: [b]res://addons/reactivex/operators/_skipuntilwithtime.gd[/b]
func skip_until_with_time(start_time : float, time_absolute : bool = false, scheduler : SchedulerBase = null) -> Callable:
	return _SkipUntilWithTime_.skip_until_with_time_(start_time, time_absolute, scheduler)

## See: [b]res://addons/reactivex/operators/_skipwhile.gd[/b]
func skip_while(predicate : Callable) -> Callable:
	return _SkipWhile_.skip_while_(predicate)

## See: [b]res://addons/reactivex/operators/_skipwhile.gd[/b]
func skip_while_indexed(predicate : Callable) -> Callable:
	return _SkipWhile_.skip_while_indexed_(predicate)

## See: [b]res://addons/reactivex/operators/_skipwithtime.gd[/b]
func skip_with_time(duration : float, scheduler : SchedulerBase = null) -> Callable:
	return _SkipWithTime_.skip_with_time_(duration, scheduler)

## See: [b]res://addons/reactivex/operators/_slice.gd[/b]
func slice(start : int = 0, stop : int = GDRx.util.MAX_SIZE, step : int = 1) -> Callable:
	return _Slice_.slice_(start, stop, step)

## See: [b]res://addons/reactivex/operators/_some.gd[/b]
func some(predicate = null) -> Callable:
	return _Some_.some_(predicate)

## See: [b]res://addons/reactivex/operators/_startswith.gd[/b]
func start_with(args) -> Callable:
	return _StartWith_.start_with_(args)

## See: [b]res://addons/reactivex/operators/_subscribeon.gd[/b]
func subscribe_on(scheduler : SchedulerBase) -> Callable:
	return _SubscribeOn_.subscribe_on_(scheduler)

## See: [b]res://addons/reactivex/operators/_sum.gd[/b]
func sum(key_mapper = null) -> Callable:
	return _Sum_.sum_(key_mapper)

## See: [b]res://addons/reactivex/operators/_switchlatest.gd[/b]
func switch_latest() -> Callable:
	return _SwitchLatest_.switch_latest_()

## See: [b]res://addons/reactivex/operators/_take.gd[/b]
func take(count_ : int) -> Callable:
	return _Take_.take_(count_)

## See: [b]res://addons/reactivex/operators/_takelast.gd[/b]
func take_last(count_ : int) -> Callable:
	return _TakeLast_.take_last_(count_)

## See: [b]res://addons/reactivex/operators/_takelastbuffer.gd[/b]
func take_last_buffer(count_ : int) -> Callable:
	return _TakeLastBuffer_.take_last_buffer_(count_)

## See: [b]res://addons/reactivex/operators/_takelastwithtime.gd[/b]
func take_last_with_time(duration : float, scheduler : SchedulerBase = null) -> Callable:
	return _TakeLastWithTime_.take_last_with_time_(duration, scheduler)

## See: [b]res://addons/reactivex/operators/_takeuntil.gd[/b]
func take_until(other : Observable) -> Callable:
	return _TakeUntil_.take_until_(other)

## See: [b]res://addons/reactivex/operators/_takeuntilwithtime.gd[/b]
func take_until_with_time(end_time : float, absolute : bool = false, scheduler : SchedulerBase = null) -> Callable:
	return _TakeUntilWithTime_.take_until_with_time_(end_time, absolute, scheduler)

## See: [b]res://addons/reactivex/operators/_takewhile.gd[/b]
func take_while(predicate : Callable = GDRx.basic.default_condition, inclusive : bool = false) -> Callable:
	return _TakeWhile_.take_while_(predicate, inclusive)

## See: [b]res://addons/reactivex/operators/_takewhile.gd[/b]
func take_while_indexed(predicate : Callable = GDRx.basic.default_condition, inclusive : bool = false) -> Callable:
	return _TakeWhile_.take_while_indexed_(predicate, inclusive)

## See: [b]res://addons/reactivex/operators/_takewithtime.gd[/b]
func take_with_time(duration : float, scheduler : SchedulerBase = null) -> Callable:
	return _TakeWithTime_.take_with_time_(duration, scheduler) 

## See: [b]res://addons/reactivex/operators/_throttlefirst.gd[/b]
func throttle_first(window_duration : float, scheduler : SchedulerBase = null) -> Callable:
	return _ThrottleFirst_.throttle_first_(window_duration, scheduler)

## See: [b]res://addons/reactivex/operators/_timeinterval.gd[/b]
func time_interval(scheduler : SchedulerBase = null) -> Callable:
	return _TimeInterval_.time_interval_(scheduler)

## See: [b]res://addons/reactivex/operators/_timeout.gd[/b]
func timeout(duetime : float, absolute : bool = false, other : Observable = null, scheduler : SchedulerBase = null) -> Callable:
	return _Timeout_.timeout_(duetime, absolute, other, scheduler)

## See: [b]res://addons/reactivex/operators/_timeoutwithmapper.gd[/b]
func timeout_with_mapper(first_timeout : Observable = null, timeout_duration_mapper : Callable = func(__) -> Observable: return GDRx.obs.never(), other : Observable = null) -> Callable:
	return _TimeoutWithMapper_.timeout_with_mapper_(first_timeout, timeout_duration_mapper, other)

## See: [b]res://addons/reactivex/operators/_timestamp.gd[/b]
func timestamp(scheduler : SchedulerBase = null) -> Callable:
	return _TimeStamp_.timestamp_(scheduler)

## See: [b]res://addons/reactivex/operators/_todict.gd[/b]
func to_dict(key_mapper : Callable, element_mapper : Callable = GDRx.basic.identity) -> Callable:
	return _ToDict_.to_dict_(key_mapper, element_mapper)

## See: [b]res://addons/reactivex/operators/_toiterable.gd[/b]
func to_iterable() -> Callable:
	return _ToIterable_.to_iterable_()

## See: [b]res://addons/reactivex/operators/_tolist.gd[/b]
func to_list() -> Callable:
	return _ToList_.to_list_()

## See: [b]res://addons/reactivex/operators/_toset.gd[/b]
func to_set() -> Callable:
	return _ToSet_.to_set_()

## See: [b]res://addons/reactivex/operators/_whiledo.gd[/b]
func while_do(condition : Callable = GDRx.basic.default_condition) -> Callable:
	return _WhileDo_.while_do_(condition)

## See: [b]res://addons/reactivex/operators/_window.gd[/b]
func window_toggle(openings : Observable, closing_mapper : Callable) -> Callable:
	return _Window_.window_toggle_(openings, closing_mapper)

## See: [b]res://addons/reactivex/operators/_window.gd[/b]
func window(boundaries : Observable) -> Callable:
	return _Window_.window_(boundaries)

## See: [b]res://addons/reactivex/operators/_window.gd[/b]
func window_when(closing_mapper : Callable) -> Callable:
	return _Window_.window_when_(closing_mapper)

## See: [b]res://addons/reactivex/operators/_windowwithcount.gd[/b]
func window_with_count(count_ : int, skip_ = null) -> Callable:
	return _WindowWithCount_.window_with_count_(count_, skip_)

## See: [b]res://addons/reactivex/operators/_windowwithtime.gd[/b]
func window_with_time(timespan : float, timeshift = null, scheduler : SchedulerBase = null) -> Callable:
	return _WindowWithTime_.window_with_time_(timespan, timeshift, scheduler)

## See: [b]res://addons/reactivex/operators/_windowwithtimeorcount.gd[/b]
func window_with_time_or_count(timespan : float, count_ : int, scheduler : SchedulerBase = null) -> Callable:
	return _WindowWithTimeOrCount_.window_with_time_or_count_(timespan, count_, scheduler)

## See: [b]res://addons/reactivex/operators/_withlatestfrom.gd[/b]
func with_latest_from(sources) -> Callable:
	return _WithLatestFrom_.with_latest_from_(sources)

## See: [b]res://addons/reactivex/operators/_zip.gd[/b]
func zip(args) -> Callable:
	return _Zip_.zip_(args)

## See: [b]res://addons/reactivex/operators/_zip.gd[/b]
func zip_with_iterable(seq : IterableBase) -> Callable:
	return _Zip_.zip_with_iterable_(seq)
