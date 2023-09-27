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

func _init(source_ : ObservableBase, subject_ : SubjectBase):
	self.subject = subject_
	self.has_subscription = false
	self.subscription = null
	self.source = source_
	
	super._init()

func _subscribe_core(
	observer : ObserverBase,
	scheduler : SchedulerBase = null
) -> DisposableBase:
	return self.subject.subscribe(observer, GDRx.basic.noop, GDRx.basic.noop, scheduler)

## Connects the observable
func connect_observable(scheduler : SchedulerBase = null) -> DisposableBase:
	if not self.has_subscription:
		self.has_subscription = true
		
		var dispose = func():
			self.has_subscription = false
		
		var subscription_ = self.source.subscribe(self.subject, GDRx.basic.noop, GDRx.basic.noop, scheduler)
		self.subscription = CompositeDisposable.new([subscription_, Disposable.new(dispose)])
	
	return self.subscription

## Returns an observable sequence that stays connected to the
##        source indefinitely to the observable sequence.
##        Providing a [i]subscriber_count[/i] will cause it to [method connect_observable] after
##        that many subscriptions occur. A [i]subscriber_count[/i] of 0 will
##        result in emissions firing immediately without waiting for
##        subscribers.
func auto_connect_observable(subscriber_count : int = 1) -> Observable:
	var connectable_subscription : Array[DisposableBase] = [null]
	@warning_ignore("shadowed_variable")
	var count = [0]
	@warning_ignore("shadowed_variable")
	var source = self
	@warning_ignore("shadowed_variable_base_class")
	var is_connected = [false]
	
	if subscriber_count == 0:
		connectable_subscription[0] = source.connect_observable()
		is_connected[0] = true
	
	@warning_ignore("shadowed_variable")
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		count[0] += 1
		var should_connect = count[0] == subscriber_count and not is_connected[0]
		var _subscription = source.subscribe(observer)
		if should_connect:
			connectable_subscription[0] = source.connect_observable(scheduler)
			is_connected[0] = true
		
		var dispose = func():
			_subscription.dispose()
			count[0] -= 1
			is_connected[0] = false
		
		return Disposable.new(dispose)
	
	return Observable.new(subscribe)
