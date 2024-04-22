extends SubjectBase
class_name Subject

var is_stopped : bool
var lock : RLock

var is_disposed : bool
var observers : Array[ObserverBase]
var error_value

var this

## View to the [Observable] behavior of the [Subject]
var obs : Observable:
	get: return self.as_observable()
## View to the [ObserverBase] behavior of the [Subject]
var obv : ObserverBase:
	get: return self.as_observer()

func _init():
	this = self
	this.unreference()
	
	self.is_stopped = false
	self.lock = RLock.new()
	
	self.is_disposed = false
	self.observers = []
	self.error_value = null

func check_disposed():
	if self.is_disposed:
		DisposedError.raise()
		return false
	return true

## Subscribe an observer to the observable sequence.
## [br]
## You may subscribe using an observer or callbacks, not both; if the first
## argument is an instance of [Observer] ([ObserverBase]) or if
## it has a [Callable] attribute named [code]on_next[/code], then any callback
## arguments will be ignored.
## [br][br]
## [b]Examples:[/b]
##    [codeblock]
##    source.subscribe(observer)
##    source.subscribe(on_next)
##    source.subscribe(on_next, on_error)
##    source.subscribe(on_next, on_error, on_completed)
##    source.subscribe(on_next, on_error, on_completed, scheduler)
##    [/codeblock]
## [br]
## [b]Args:[/b]
## [br]
##    [code]observer[/code] The object that is to receive
##    notifications.
## [br]
##    [code]on_error[/code] [Optional] Action to invoke upon exceptional termination
##    of the observable sequence.
## [br]
##    [code]on_completed[/code] [Optional] Action to invoke upon graceful termination
##    of the observable sequence.
## [br]
##    [code]on_next[/code] Action to invoke for each element in the
##    observable sequence.
## [br]
##    [code]scheduler[/code] [Optional] The default scheduler to use for this
##    subscription.
## [br][br]
## [b]Returns:[/b]
## [br]
##    Disposable object representing an observer's subscription to
##    the observable sequence.
func subscribe(
	_on_next = null, # Callable or Observer or Object with callbacks
	_on_error : Callable = GDRx.basic.noop,
	_on_completed : Callable = GDRx.basic.noop,
	scheduler : SchedulerBase = null) -> DisposableBase:
		if _on_next == null:
			_on_next = GDRx.basic.noop
		
		if _on_next is ObserverBase:
			var _obv : ObserverBase = _on_next
			_on_next = func(i): _obv.on_next.call(i)
			_on_error = func(e): _obv.on_error.call(e)
			_on_completed = func(): _obv.on_completed.call()
		elif _on_next is Object and _on_next.has_method("on_next"):
			var _obv : Object = _on_next
			if _obv.has_method("on_next"):
				_on_next = func(i): _obv.on_next.call(i)
			if _obv.has_method("on_error"):
				_on_error = func(e): _obv.on_error.call(e)
			if _obv.has_method("on_completed"):
				_on_completed = func(): _obv.on_completed.call()
		
		var auto_detach_observer : AutoDetachObserver = AutoDetachObserver.new(
			_on_next, _on_error, _on_completed
		)
		
		var fix_subscriber = func(subscriber) -> DisposableBase:
			if subscriber is DisposableBase or subscriber.has_method("dispose"):
				return subscriber
			return Disposable.new(subscriber)
		
		var set_disposable = func(__ : SchedulerBase = null, ___ = null):
			var subscriber = RefValue.Null()
			if not GDRx.try(func():
				subscriber.v = self._subscribe_core(auto_detach_observer, scheduler)
			) \
			.catch("Error", func(err):
				if not auto_detach_observer.fail(err):
					GDRx.raise(err)
			) \
			.end_try_catch():
				auto_detach_observer.subscription = fix_subscriber.call(subscriber.v)
		
		var current_thread_scheduler = CurrentThreadScheduler.singleton()
		if current_thread_scheduler.schedule_required():
			current_thread_scheduler.schedule(set_disposable)
		else:
			set_disposable.call()
		
		return Disposable.new(func(): auto_detach_observer.dispose())

func _subscribe_core(
	observer : ObserverBase,
	_scheduler : SchedulerBase = null) -> DisposableBase:
		var __ = LockGuard.new(self.lock)
		self.check_disposed()
		if not self.is_stopped:
			self.observers.append(observer)
			return InnerSubscription.new(self, observer)
		
		if self.error_value != null:
			observer.on_error(self.error_value)
		else:
			observer.on_completed()
		return Disposable.new()

func on_next(i):
	if true:
		var __ = LockGuard.new(self.lock)
		self.check_disposed()
	if not self.is_stopped:
		self._on_next_core(i)

func _on_next_core(i):
	var observers_ : Array[ObserverBase]
	if true:
		var __ = LockGuard.new(this.lock)
		observers_ = self.observers.duplicate()
	
	for observer in observers_:
		observer.on_next(i)

func on_error(e):
	if true:
		var __ = LockGuard.new(self.lock)
		self.check_disposed()
	if not self.is_stopped:
		self.is_stopped = true
		self._on_error_core(e)

func _on_error_core(e):
	var observers_ : Array[ObserverBase]
	if true:
		var __ = LockGuard.new(this.lock)
		observers_ = self.observers.duplicate()
		self.observers.clear()
		self.error_value = e
	
	for observer in observers_:
		observer.on_error(e)

func on_completed():
	if true:
		var __ = LockGuard.new(self.lock)
		self.check_disposed()
	if not self.is_stopped:
		self.is_stopped = true
		self._on_completed_core()

func _on_completed_core():
	var observers_ : Array[ObserverBase]
	if true:
		var __ = LockGuard.new(this.lock)
		observers_ = self.observers.duplicate()
		self.observers.clear()
	
	for observer in observers_:
		observer.on_completed()

func dispose():
	if true:
		var __ = LockGuard.new(this.lock)
		this.is_disposed = true
		this.observers.clear()
		this.error_value = null
		this.is_stopped = true

func fail(e):
	if not self.is_stopped:
		self.is_stopped = true
		self._on_error_core(e)
		return true
	return false

func throw(error : ThrowableBase):
	print_stack()
	GDRx.raise(error)

func to_notifier() -> Callable:
	return func(notifier : Notification): 
		return notifier.accept(self.as_observer())

func as_observer() -> ObserverBase:
	return _Observer.new(self)

func as_observable() -> Observable:
	return _Observable.new(self)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		this.dispose()

## Anonymous [ObserverBase]
class _Observer extends ObserverBase:
	var _subject : Subject
	func _init(subject : Subject):
		self._subject = subject
	## Called when the [Observable] emits a new item on the stream
	func on_next(i):
		self._subject.on_next(i)
	## Called when the [Observable] emits an error on the stream
	func on_error(e):
		self._subject.on_error(e)
	## Called when the [Observable] is finished and no more items are sent.
	func on_completed():
		self._subject.on_completed()

## Anonymous [ObservableBase]
class _Observable extends Observable:
	var _subject : Subject
	func _init(subject : Subject):
		self._subject = subject
	func _subscribe_core(
		observer : ObserverBase, scheduler : SchedulerBase = null) -> DisposableBase:
			return self._subject.subscribe1(observer, scheduler)

# ============================================================================ #
# AWAIT                                                                        #
# ============================================================================ #

## Coroutine which finishes when next item is emitted.
## [br][br]
## [code]var item = await obs.next()[/code]
func next() -> Variant:
	return await ObservableAwait.new(obs).on_next()

## Coroutine which finishes when sequence terminates with error.
## [br][br]
## [code]var err = await obs.error()[/code]
func error() -> Variant:
	return await ObservableAwait.new(obs).on_error()

## Coroutine which finishes when sequence terminates gracefully.
## [br][br]
## [code]await obs.completed()[/code]
func completed():
	return await ObservableAwait.new(obs).on_completed()

# ============================================================================ #
# PIPE                                                                         #
# ============================================================================ #

## Pipe operator
func pipe0() -> Variant:
	return GDRx.pipe.pipe(obs, GDRx.util.Iter([]))

## Pipe operator
func pipe1(__fn1 : Callable) -> Variant:
	return GDRx.pipe.pipe(obs, GDRx.util.Iter([__fn1]))

## Pipe operator
func pipe2(
	__fn1 : Callable,
	__fn2 : Callable
) -> Variant:
	return GDRx.pipe.pipe(obs, GDRx.util.Iter([__fn1, __fn2]))

## Pipe operator
func pipe3( 
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable
) -> Variant:
	return GDRx.pipe.pipe(obs, GDRx.util.Iter([__fn1, __fn2, __fn3]))

## Pipe operator
func pipe4( 
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable
) -> Variant:
	return GDRx.pipe.pipe(obs, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4]))

## Pipe operator
func pipe5(
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable,
	__fn5 : Callable
) -> Variant:
	return GDRx.pipe.pipe(obs, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4, __fn5]))

## Pipe operator
func pipe6(
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable,
	__fn5 : Callable,
	__fn6 : Callable
) -> Variant:
	return GDRx.pipe.pipe(obs, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4, __fn5, __fn6]))

## Pipe operator
func pipe7(
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable,
	__fn5 : Callable,
	__fn6 : Callable,
	__fn7 : Callable
) -> Variant:
	return GDRx.pipe.pipe(obs, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4, __fn5, __fn6, __fn7]))

## Pipe operator
func pipe8( 
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable,
	__fn5 : Callable,
	__fn6 : Callable,
	__fn7 : Callable,
	__fn8 : Callable
) -> Variant:
	return GDRx.pipe.pipe(obs, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4, __fn5, __fn6, __fn7, __fn8]))

## Pipe operator
func pipe9(
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable,
	__fn5 : Callable,
	__fn6 : Callable,
	__fn7 : Callable,
	__fn8 : Callable,
	__fn9 : Callable
) -> Variant:
	return GDRx.pipe.pipe(obs, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4, __fn5, __fn6, __fn7, __fn8, __fn9]))

## Pipe operator taking a list
func pipea(arr : Array):
	return GDRx.pipe.pipe(obs, GDRx.util.Iter(arr))

## Compose multiple operators left to right.
## [br]
## Composes zero or more operators into a functional composition.
## The operators are composed from left to right. A composition of zero
## operators gives back the original source.
## [br][br]
## [b]Examples:[/b]
##    [codeblock]
##    source.pipe0() == source
##    source.pipe1(f) == f(source)
##    source.pipe2(g, f) == f(g(source))
##    source.pipe3(h, g, f) == f(g(h(source)))
##    [/codeblock]
## [br]
## [b]Args:[/b]
## [br]
##    [code]operators[/code] Sequence of operators.
## [br][br]
## [b]Returns:[/b]
## [br]
##    The composed observable.
func pipe(fns : IterableBase) -> Variant:
	return GDRx.pipe.compose(fns).call(obs)

# ============================================================================ #
# OPERATORS                                                                    #
# ============================================================================ #

## See: [b]res://addons/reactivex/operators/connectable/_refcount.gd[/b]
func ref_count() -> Observable:
	return GDRx.op.ref_count().call(obs)

## See: [b]res://addons/reactivex/operators/_all.gd[/b]
func all(predicate : Callable) -> Observable:
	return GDRx.op.all(predicate).call(obs)

## See: [b]res://addons/reactivex/operators/_amb.gd[/b]
func amb(right_source : Observable) -> Observable:
	return GDRx.op.amb(right_source).call(obs)

## See: [b]res://addons/reactivex/operators/_average.gd[/b]
func average(key_mapper = null) -> Observable:
	return GDRx.op.average(key_mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_buffer.gd[/b]
func buffer(boundaries : Observable) -> Observable:
	return GDRx.op.buffer(boundaries).call(obs)

## See: [b]res://addons/reactivex/operators/_buffer.gd[/b]
func buffer_when(closing_mapper : Callable) -> Observable:
	return GDRx.op.buffer_when(closing_mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_buffer.gd[/b]
func buffer_toggle(openings : Observable, closing_mapper : Callable) -> Observable:
	return GDRx.op.buffer_toggle(openings, closing_mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_buffer.gd[/b]
func buffer_with_count(count_ : int, skip_ = null) -> Observable:
	return GDRx.op.buffer_with_count(count_, skip_).call(obs)

## See: [b]res://addons/reactivex/operators/_bufferwithtime.gd[/b]
func buffer_with_time(timespan : float, timeshift = null, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.buffer_with_time(timespan, timeshift, scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_bufferwithtimeourcount.gd[/b]
func buffer_with_time_or_count(timespan : float, count_ : int, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.buffer_with_time_or_count(timespan, count_, scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_catch.gd[/b]
func catch_handler(handler : Callable) -> Observable:
	return GDRx.op.catch_handler(obs, handler)

## See: [b]res://addons/reactivex/operators/_catch.gd[/b]
func catch(handler) -> Observable:
	return GDRx.op.catch(handler).call(obs)

## See: [b]res://addons/reactivex/operators/_combinelatest.gd[/b]
func combine_latest(others) -> Observable:
	return GDRx.op.combine_latest(others).call(obs)

## See: [b]res://addons/reactivex/operators/_concat.gd[/b]
func concat(sources) -> Observable:
	return GDRx.op.concat(sources).call(obs)

## See: [b]res://addons/reactivex/operators/_contains.gd[/b]
func contains(value, comparer = GDRx.basic.default_comparer) -> Observable:
	return GDRx.op.contains(value, comparer).call(obs)

## See: [b]res://addons/reactivex/operators/_count.gd[/b]
func count(predicate = null) -> Observable:
	return GDRx.op.count(predicate).call(obs)

## See: [b]res://addons/reactivex/operators/_debounce.gd[/b]
func debounce(duetime : float, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.debounce(duetime, scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_debounce.gd[/b]
func throttle_with_mapper(throttle_duration_mapper : Callable) -> Observable:
	return GDRx.op.throttle_with_mapper(throttle_duration_mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_defaultifempty.gd[/b]
func default_if_empty(default_value = null) -> Observable:
	return GDRx.op.default_if_empty(default_value).call(obs)

## See: [b]res://addons/reactivex/operators/_delay.gd[/b]
func observable_delay_timespan(duetime : float, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.observable_delay_timespan(obs, duetime, scheduler)

## See: [b]res://addons/reactivex/operators/_delay.gd[/b]
func delay(duetime : float, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.delay(duetime, scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_delaysubscription.gd[/b]
func delay_subscription(duetime : float, time_absolute : bool = false, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.delay_subscription(duetime, time_absolute, scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_delaywithmapper.gd[/b]
func delay_with_mapper(subscription_delay = null, delay_duration_mapper = null) -> Observable:
	return GDRx.op.delay_with_mapper(subscription_delay, delay_duration_mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_dematerialize.gd[/b]
func dematerialize() -> Observable:
	return GDRx.op.dematerialize().call(obs)

## See: [b]res://addons/reactivex/operators/_distinct.gd[/b]
func distinct(key_mapper : Callable = GDRx.basic.identity, comparer : Callable = GDRx.basic.default_comparer) -> Observable:
	return GDRx.op.distinct(key_mapper, comparer).call(obs)

## See: [b]res://addons/reactivex/operators/_distinctuntilchanged.gd[/b]
func distinct_until_changed(key_mapper : Callable = GDRx.basic.identity, comparer : Callable = GDRx.basic.default_comparer) -> Observable:
	return GDRx.op.distinct_until_changed(key_mapper, comparer).call(obs)

## See: [b]res://addons/reactivex/operators/_do.gd[/b]
func do_action(on_next = null, on_error = null, on_completed = null) -> Observable:
	return GDRx.op.do_action(on_next, on_error, on_completed).call(obs)

## See: [b]res://addons/reactivex/operators/_do.gd[/b]
func do(observer : ObserverBase) -> Observable:
	return GDRx.op.do(observer).call(obs)

## See: [b]res://addons/reactivex/operators/_do.gd[/b]
func do_after_next(after_next : Callable) -> Observable:
	return GDRx.op.do_after_next(obs, after_next)

## See: [b]res://addons/reactivex/operators/_do.gd[/b]
func do_on_subscribe(on_subscribe : Callable) -> Observable:
	return GDRx.op.do_on_subscribe(obs, on_subscribe)

## See: [b]res://addons/reactivex/operators/_do.gd[/b]
func do_on_dispose(on_dispose : Callable) -> Observable:
	return GDRx.op.do_on_dispose(obs, on_dispose)

## See: [b]res://addons/reactivex/operators/_do.gd[/b]
func do_on_terminate(on_terminate : Callable) -> Observable:
	return GDRx.op.do_on_terminate(obs, on_terminate)

## See: [b]res://addons/reactivex/operators/_do.gd[/b]
func do_after_terminate(after_terminate : Callable) -> Observable:
	return GDRx.op.do_after_terminate(obs, after_terminate)

## See: [b]res://addons/reactivex/operators/_do.gd[/b]
func do_finally(finally_action_ : Callable) -> Observable:
	return GDRx.op.do_finally(finally_action_).call(obs)

## See: [b]res://addons/reactivex/operators/_dowhile.gd[/b]
func do_while(condition : Callable) -> Observable:
	return GDRx.op.do_while(condition).call(obs)

## See: [b]res://addons/reactivex/operators/_elementordefault.gd[/b]
func element_at_or_default(index : int, has_default : bool = false, default_value = GDRx.util.GetNotSet()) -> Observable:
	return GDRx.op.element_at_or_default(index, has_default, default_value).call(obs)

## See: [b]res://addons/reactivex/operators/_exclusive.gd[/b]
func exclusive() -> Observable:
	return GDRx.op.exclusive().call(obs)

## See: [b]res://addons/reactivex/operators/_expand.gd[/b]
func expand(mapper : Callable) -> Observable:
	return GDRx.op.expand(mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_filter.gd[/b]
func filter(predicate : Callable = GDRx.basic.default_condition) -> Observable:
	return GDRx.op.filter(predicate).call(obs)

## See: [b]res://addons/reactivex/operators/_filter.gd[/b]
func filter_indexed(predicate : Callable = GDRx.basic.default_condition) -> Observable:
	return GDRx.op.filter_indexed(predicate).call(obs)

## See: [b]res://addons/reactivex/operators/_finallyaction.gd[/b]
func finally_action(action : Callable) -> Observable:
	return GDRx.op.finally_action(action).call(obs)

## See: [b]res://addons/reactivex/operators/_find.gd[/b]
func find_value(predicate : Callable, yield_index : bool) -> Observable:
	return GDRx.op.find_value(predicate, yield_index).call(obs)

## See: [b]res://addons/reactivex/operators/_first.gd[/b]
func first(predicate = null) -> Observable:
	return GDRx.op.first(predicate).call(obs)

## See: [b]res://addons/reactivex/operators/_firstordefault.gd[/b]
func first_or_default_async(has_default : bool = false, default_value = null) -> Observable:
	return GDRx.op.first_or_default_async(has_default, default_value).call(obs)

## See: [b]res://addons/reactivex/operators/_firstordefault.gd[/b]
func first_or_default(predicate = null, default_value = null) -> Observable:
	return GDRx.op.first_or_default(predicate, default_value).call(obs)

## See: [b]res://addons/reactivex/operators/_flatmap.gd[/b]
func flat_map(mapper = null) -> Observable:
	return GDRx.op.flat_map(mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_flatmap.gd[/b]
func flat_map_indexed(mapper_indexed = null) -> Observable:
	return GDRx.op.flat_map_indexed(mapper_indexed).call(obs)

## See: [b]res://addons/reactivex/operators/_flatmap.gd[/b]
func flat_map_latest(mapper = null) -> Observable:
	return GDRx.op.flat_map_latest(mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_forkjoin.gd[/b]
func fork_join(args) -> Observable:
	return GDRx.op.fork_join(args).call(obs)

## See: [b]res://addons/reactivex/operators/_groupby.gd[/b]
func group_by(key_mapper : Callable, element_mapper = null, subject_mapper = null) -> Observable:
	return GDRx.op.group_by(key_mapper, element_mapper, subject_mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_groupbyuntil.gd[/b]
func group_by_until(key_mapper : Callable, duration_mapper : Callable, element_mapper = null, subject_mapper = null) -> Observable:
	return GDRx.op.group_by_until(key_mapper, duration_mapper, element_mapper, subject_mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_groupjoin.gd[/b]
func group_join(right : Observable, left_duration_mapper : Callable, right_duration_mapper : Callable) -> Observable:
	return GDRx.op.group_join(right, left_duration_mapper, right_duration_mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_ignoreelements.gd[/b]
func ignore_elements() -> Observable:
	return GDRx.op.ignore_elements().call(obs)

## See: [b]res://addons/reactivex/operators/_isempty.gd[/b]
func is_empty() -> Observable:
	return GDRx.op.is_empty().call(obs)

## See: [b]res://addons/reactivex/operators/_join.gd[/b]
func join(right : Observable, left_duration_mapper : Callable, right_duration_mapper : Callable) -> Observable:
	return GDRx.op.join(right, left_duration_mapper, right_duration_mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_last.gd[/b]
func last(predicate = null) -> Observable:
	return GDRx.op.last(predicate).call(obs)

## See: [b]res://addons/reactivex/operators/_lastordefault.gd[/b]
func last_or_default_async(has_default : bool = false, default_value = null) -> Observable:
	return GDRx.op.last_or_default_async(obs, has_default, default_value)

## See: [b]res://addons/reactivex/operators/_lastordefault.gd[/b]
func last_or_default(default_value = null, predicate = null) -> Observable:
	return GDRx.op.last_or_default(default_value, predicate).call(obs)

## See: [b]res://addons/reactivex/operators/_map.gd[/b]
func map(mapper : Callable = GDRx.basic.identity) -> Observable:
	return GDRx.op.map(mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_map.gd[/b]
func map_indexed(mapper_indexed : Callable = GDRx.basic.identity) -> Observable:
	return GDRx.op.map_indexed(mapper_indexed).call(obs)

## See: [b]res://addons/reactivex/operators/_materialize.gd[/b]
func materialize() -> Observable:
	return GDRx.op.materialize().call(obs)

## See: [b]res://addons/reactivex/operators/_max.gd[/b]
@warning_ignore("shadowed_global_identifier")
func max(comparer = null) -> Observable:
	return GDRx.op.max(comparer).call(obs)

## See: [b]res://addons/reactivex/operators/_maxby.gd[/b]
func max_by(key_mapper : Callable, comparer = null) -> Observable:
	return GDRx.op.max_by(key_mapper, comparer).call(obs)

## See: [b]res://addons/reactivex/operators/_merge.gd[/b]
func merge(sources, max_concorrent : int = -1) -> Observable:
	return GDRx.op.merge(sources, max_concorrent).call(obs)

## See: [b]res://addons/reactivex/operators/_merge.gd[/b]
func merge_all() -> Observable:
	return GDRx.op.merge_all().call(obs)

## See: [b]res://addons/reactivex/operators/_min.gd[/b]
@warning_ignore("shadowed_global_identifier")
func min(comparer = null) -> Observable:
	return GDRx.op.min(comparer).call(obs)

## See: [b]res://addons/reactivex/operators/_minby.gd[/b]
func extrema_by(key_mapper : Callable, comparer : Callable) -> Observable:
	return GDRx.op.extrema_by(obs, key_mapper, comparer)

## See: [b]res://addons/reactivex/operators/_minby.gd[/b]
func min_by(key_mapper : Callable, comparer = null) -> Observable:
	return GDRx.op.min_by(key_mapper, comparer).call(obs)

## See: [b]res://addons/reactivex/operators/_multicast.gd[/b]
func multicast(subject : SubjectBase = null, subject_factory = null, mapper = null) -> Observable:
	return GDRx.op.multicast(subject, subject_factory, mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_observeon.gd[/b]
func observe_on(scheduler : SchedulerBase) -> Observable:
	return GDRx.op.observe_on(scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_oftype.gd[/b]
func oftype(type, push_err : bool = true, type_equality : Callable = GDRx.basic.default_type_equality) -> Observable:
	return GDRx.op.oftype(type, push_err, type_equality).call(obs)

## See: [b]res://addons/reactivex/operators/_onerrorresumenext.gd[/b]
func on_error_resume_next(second : Observable) -> Observable:
	return GDRx.op.on_error_resume_next(second).call(obs)

## See: [b]res://addons/reactivex/operators/_pairwise.gd[/b]
func pairwise() -> Observable:
	return GDRx.op.pairwise().call(obs)

## See: [b]res://addons/reactivex/operators/_partiton.gd[/b]
func partition(predicate : Callable = GDRx.basic.default_condition) -> Array[Observable]:
	return GDRx.op.partition(predicate).call(obs)

## Alternative to [method partition] but returning type an [IterableBase] containing.
## the partitioned [Observable]s.
func partitionit(predicate : Callable = GDRx.basic.default_condition) -> IterableBase:
	return Iterator.to_iterable(self.partition(predicate))

## See: [b]res://addons/reactivex/operators/_partition.gd[/b]
func partition_indexed(predicate_indexed : Callable = GDRx.basic.default_condition) -> Observable:
	return GDRx.op.partition_indexed(predicate_indexed).call(obs)

## See: [b]res://addons/reactivex/operators/_pluck.gd[/b]
func pluck(key) -> Observable:
	return GDRx.op.pluck(key).call(obs)

## See: [b]res://addons/reactivex/operators/_pluck.gd[/b]
func pluck_attr(prop : String) -> Observable:
	return GDRx.op.pluck_attr(prop).call(obs)

## See: [b]res://addons/reactivex/operators/_publish.gd[/b]
func publish(mapper = null) -> Observable:
	return GDRx.op.publish(mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_publish.gd[/b]
func share() -> Observable:
	return GDRx.op.share().call(obs)

## See: [b]res://addons/reactivex/operators/_publishvalue.gd[/b]
func publish_value(initial_value, mapper = null) -> Observable:
	return GDRx.op.publish_value(initial_value, mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_reduce.gd[/b]
func reduce(accumulator : Callable, seed_ = GDRx.util.GetNotSet()) -> Observable:
	return GDRx.op.reduce(accumulator, seed_).call(obs)

## See: [b]res://addons/reactivex/operators/_repeat.gd[/b]
func repeat(repeat_count = null) -> Observable:
	return GDRx.op.repeat(repeat_count).call(obs)

## See: [b]res://addons/reactivex/operators/_replay.gd[/b]
func replay(mapper = null, buffer_size = null, window_ = null, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.replay(mapper, buffer_size, window_, scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_retry.gd[/b]
func retry(retry_count : int = -1) -> Observable:
	return GDRx.op.retry(retry_count).call(obs)

## See: [b]res://addons/reactivex/operators/_sample.gd[/b]
func sample_observable(sampler : Observable) -> Observable:
	return GDRx.op.sample_observable(obs, sampler)

## See: [b]res://addons/reactivex/operators/_sample.gd[/b]
func sample(sampler : Observable, sampler_time : float = NAN, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.sample(sampler, sampler_time, scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_scan.gd[/b]
func scan(accumulator : Callable, seed_ = GDRx.util.GetNotSet()) -> Observable:
	return GDRx.op.scan(accumulator, seed_).call(obs)

## See: [b]res://addons/reactivex/operators/_sequenceequal.gd[/b]
func sequence_equal(second, comparer  = null, second_it : IterableBase = null) -> Observable:
	return GDRx.op.sequence_equal(second, comparer, second_it).call(obs)

## See: [b]res://addons/reactivex/operators/_single.gd[/b]
func single(predicate = null) -> Observable:
	return GDRx.op.single(predicate).call(obs)

## See: [b]res://addons/reactivex/operators/_singleordefault.gd[/b]
func single_or_default_async(has_default : bool = false, default_value = null) -> Observable:
	return GDRx.op.single_or_default_async(has_default, default_value).call(obs)

## See: [b]res://addons/reactivex/operators/_singleordefault.gd[/b]
func single_or_default(predicate = null, default_value = null) -> Observable:
	return GDRx.op.single_or_default(predicate, default_value).call(obs)

## See: [b]res://addons/reactivex/operators/_skip.gd[/b]
func skip(count_ : int) -> Observable:
	return GDRx.op.skip(count_).call(obs)

## See: [b]res://addons/reactivex/operators/_skiplast.gd[/b]
func skip_last(count_ : int) -> Observable:
	return GDRx.op.skip_last(count_).call(obs)

## See: [b]res://addons/reactivex/operators/_skiplastwithtime.gd[/b]
func skip_last_with_time(duration : float, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.skip_last_with_time(duration, scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_skipuntil.gd[/b]
func skip_until(other : Observable) -> Observable:
	return GDRx.op.skip_until(other).call(obs)

## See: [b]res://addons/reactivex/operators/_skipuntilwithtime.gd[/b]
func skip_until_with_time(start_time : float, time_absolute : bool = false, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.skip_until_with_time(start_time, time_absolute, scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_skipwhile.gd[/b]
func skip_while(predicate : Callable) -> Observable:
	return GDRx.op.skip_while(predicate).call(obs)

## See: [b]res://addons/reactivex/operators/_skipwhile.gd[/b]
func skip_while_indexed(predicate : Callable) -> Observable:
	return GDRx.op.skip_while_indexed(predicate).call(obs)

## See: [b]res://addons/reactivex/operators/_skipwithtime.gd[/b]
func skip_with_time(duration : float, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.skip_with_time(duration, scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_slice.gd[/b]
func slice(start : int = 0, stop : int = GDRx.util.MAX_SIZE, step : int = 1) -> Observable:
	return GDRx.op.slice(start, stop, step).call(obs)

## See: [b]res://addons/reactivex/operators/_some.gd[/b]
func some(predicate = null) -> Observable:
	return GDRx.op.some(predicate).call(obs)

## See: [b]res://addons/reactivex/operators/_startswith.gd[/b]
func start_with(args) -> Observable:
	return GDRx.op.start_with(args).call(obs)

## See: [b]res://addons/reactivex/operators/_subscribeon.gd[/b]
func subscribe_on(scheduler : SchedulerBase) -> Observable:
	return GDRx.op.subscribe_on(scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_sum.gd[/b]
func sum(key_mapper = null) -> Observable:
	return GDRx.op.sum(key_mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_switchlatest.gd[/b]
func switch_latest() -> Observable:
	return GDRx.op.switch_latest().call(obs)

## See: [b]res://addons/reactivex/operators/_take.gd[/b]
func take(count_ : int) -> Observable:
	return GDRx.op.take(count_).call(obs)

## See: [b]res://addons/reactivex/operators/_takelast.gd[/b]
func take_last(count_ : int) -> Observable:
	return GDRx.op.take_last(count_).call(obs)

## See: [b]res://addons/reactivex/operators/_takelastbuffer.gd[/b]
func take_last_buffer(count_ : int) -> Observable:
	return GDRx.op.take_last_buffer(count_).call(obs)

## See: [b]res://addons/reactivex/operators/_takelastwithtime.gd[/b]
func take_last_with_time(duration : float, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.take_last_with_time(duration, scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_takeuntil.gd[/b]
func take_until(other : Observable) -> Observable:
	return GDRx.op.take_until(other).call(obs)

## See: [b]res://addons/reactivex/operators/_takeuntilwithtime.gd[/b]
func take_until_with_time(end_time : float, absolute : bool = false, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.take_until_with_time(end_time, absolute, scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_takewhile.gd[/b]
func take_while(predicate : Callable = GDRx.basic.default_condition, inclusive : bool = false) -> Observable:
	return GDRx.op.take_while(predicate, inclusive).call(obs)

## See: [b]res://addons/reactivex/operators/_takewhile.gd[/b]
func take_while_indexed(predicate : Callable = GDRx.basic.default_condition, inclusive : bool = false) -> Observable:
	return GDRx.op.take_while_indexed(predicate, inclusive).call(obs)

## See: [b]res://addons/reactivex/operators/_takewithtime.gd[/b]
func take_with_time(duration : float, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.take_with_time(duration, scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_throttlefirst.gd[/b]
func throttle_first(window_duration : float, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.throttle_first(window_duration, scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_timeinterval.gd[/b]
func time_interval(scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.time_interval(scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_timeout.gd[/b]
func timeout(duetime : float, absolute : bool = false, other : Observable = null, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.timeout(duetime, absolute, other, scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_timeoutwithmapper.gd[/b]
func timeout_with_mapper(first_timeout : Observable = null, timeout_duration_mapper : Callable = func(__) -> Observable: return GDRx.obs.never(), other : Observable = null) -> Observable:
	return GDRx.op.timeout_with_mapper(first_timeout, timeout_duration_mapper, other).call(obs)

## See: [b]res://addons/reactivex/operators/_timestamp.gd[/b]
func timestamp(scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.timestamp(scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_todict.gd[/b]
func to_dict(key_mapper : Callable, element_mapper : Callable = GDRx.basic.identity) -> Observable:
	return GDRx.op.to_dict(key_mapper, element_mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_toiterable.gd[/b]
func to_iterable() -> Observable:
	return GDRx.op.to_iterable().call(obs)

## See: [b]res://addons/reactivex/operators/_tolist.gd[/b]
func to_list() -> Observable:
	return GDRx.op.to_list().call(obs)

## See: [b]res://addons/reactivex/operators/_toset.gd[/b]
func to_set() -> Observable:
	return GDRx.op.to_set().call(obs)

## See: [b]res://addons/reactivex/operators/_whiledo.gd[/b]
func while_do(condition : Callable = GDRx.basic.default_condition) -> Observable:
	return GDRx.op.while_do(condition).call(obs)

## See: [b]res://addons/reactivex/operators/_window.gd[/b]
func window_toggle(openings : Observable, closing_mapper : Callable) -> Observable:
	return GDRx.op.window_toggle(openings, closing_mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_window.gd[/b]
func window_with_bounds(boundaries : Observable) -> Observable:
	return GDRx.op.window(boundaries).call(obs)

## See: [b]res://addons/reactivex/operators/_window.gd[/b]
func window_when(closing_mapper : Callable) -> Observable:
	return GDRx.op.window_when(closing_mapper).call(obs)

## See: [b]res://addons/reactivex/operators/_windowwithcount.gd[/b]
func window_with_count(count_ : int, skip_ = null) -> Observable:
	return GDRx.op.window_with_count(count_, skip_).call(obs)

## See: [b]res://addons/reactivex/operators/_windowwithtime.gd[/b]
func window_with_time(timespan : float, timeshift = null, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.window_with_time(timespan, timeshift, scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_windowwithtimeorcount.gd[/b]
func window_with_time_or_count(timespan : float, count_ : int, scheduler : SchedulerBase = null) -> Observable:
	return GDRx.op.window_with_time_or_count(timespan, count_, scheduler).call(obs)

## See: [b]res://addons/reactivex/operators/_withlatestfrom.gd[/b]
func with_latest_from(sources) -> Observable:
	return GDRx.op.with_latest_from(sources).call(obs)

## See: [b]res://addons/reactivex/operators/_zip.gd[/b]
func zip(args) -> Observable:
	return GDRx.op.zip(args).call(obs)

## See: [b]res://addons/reactivex/operators/_zip.gd[/b]
func zip_with_iterable(seq : IterableBase) -> Observable:
	return GDRx.op.zip_with_iterable(seq).call(obs)

# =========================================================================== #
#   Godot-specific Operators
# =========================================================================== #

## See: [b]"res://addons/reactivex/engine/operators/_processtimeinterval.gd"[/b]
func process_time_interval(initial_time : float = 0.0) -> Observable:
	return GDRx.gd.process_time_interval(initial_time).call(obs)

## See: [b]"res://addons/reactivex/engine/operators/_processtimeinterval.gd"[/b]
func physics_time_interval(initial_time : float = 0.0) -> Observable:
	return GDRx.gd.physics_time_interval(initial_time).call(obs)

## Create a [ReadOnlyReactiveProperty] from the given sequence
func to_reactive_property(initial_value, distinct_until_changed : bool = true, raise_latest_value_on_subscribe = true) -> ReadOnlyReactiveProperty:
	return ReadOnlyReactiveProperty.new(obs, initial_value, distinct_until_changed, raise_latest_value_on_subscribe)