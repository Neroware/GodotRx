extends Observable
class_name ConnectableObservable

## A connectable observable
##
## Represents an observable that can be connected and
## disconnected.

var subject : SubjectBase
var has_subscription : bool
var subscription : DisposableBase
var source : ObservableBase

func _init(source : ObservableBase, subject : SubjectBase):
	self.subject = subject
	self.has_subscription = false
	self.subscription = null
	self.source = source
	
	super._init()

func _subscribe_core(
	observer : ObserverBase,
	scheduler : SchedulerBase = null
) -> DisposableBase:
	return self.subject.as_observable().subscribe(observer, func(e): return, func(): return, scheduler)

## Connects the observable
func connect_observable(scheduler : SchedulerBase = null) -> DisposableBase:
	if not self.has_subscription:
		self.has_subscription = true
		
		var dispose = func():
			self.has_subscription = false
		
		var subscription = self.source.subscribe(self.subject.as_observer(), func(e): return, func(): return, scheduler)
		self.subscription = CompositeDisposable.new([subscription, Disposable.new(dispose)])
	
	return self.subscription

## Returns an observable sequence that stays connected to the
##        source indefinitely to the observable sequence.
##        Providing a [i]subscriber_count[/i] will cause it to [method connect_observable] after
##        that many subscriptions occur. A [i]subscriber_count[/i] of 0 will
##        result in emissions firing immediately without waiting for
##        subscribers.
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
