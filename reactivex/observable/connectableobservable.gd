extends Observable
class_name ConnectableObservable

var _subject : SubjectBase
var _has_subscription : bool
var _subscription : DisposableBase
var _source : ObservableBase

func _init(source : ObservableBase, subject : SubjectBase):
	self._subject = subject
	self._has_subscription = false
	self._subscription = null
	self._source = source
	
	super._init()

func _subscribe_core(
	observer : ObserverBase,
	scheduler : SchedulerBase = null
) -> DisposableBase:
	return self._subject.observable().subscribe(observer, func(e): return, func(): return, scheduler)

func connect_observable(scheduler : SchedulerBase = null) -> DisposableBase:
	if not self._has_subscription:
		self._has_subscription = true
		
		var dispose = func():
			self._has_subscription = false
		
		var subscription = self._source.subscribe(self._subject.observer(), func(e): return, func(): return, scheduler)
		self._subscription = CompositeDisposable.new([subscription, Disposable.new(dispose)])
	
	return self._subscription

func auto_connect_observable(subscriber_count : int = 1) -> Observable:
	var connectable_subscription : Array[DisposableBase] = [null]
	var count = [0]
	var source = self
	var is_connected = [false]
	
	if subscriber_count == 0:
		connectable_subscription[0] = source.connect_observable()
		is_connected[0] = true
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		count[0] += 1
		var should_connect = count[0] == subscriber_count and not is_connected[0]
		var subscription = source.subscribe(observer)
		if should_connect:
			connectable_subscription[0] = source.connect_observable(scheduler)
			is_connected[0] = true
		
		var dispose = func():
			subscription.dispose()
			count[0] -= 1
			is_connected[0] = false
		
		return Disposable.new(dispose)
	
	return Observable.new(subscribe)
