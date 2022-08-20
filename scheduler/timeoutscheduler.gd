extends PeriodicScheduler
class_name TimeoutScheduler


func _init(verify_ = null):
	if not verify_ == "GDRx":
		push_error("Warning! Must only instance Scheduler from GDRx singleton!")

static func singleton() -> TimeoutScheduler:
	return GDRx.TimeoutScheduler_

func schedule(action : Callable, state = null) -> DisposableBase:
	var sad : SingleAssignmentDisposable = SingleAssignmentDisposable.new()
	
	var interval = func():
		sad.set_disposable(self.invoke_action(action, state))
	
	var timer : SceneTreeTimer = GDRx.get_tree().create_timer(0.0)
	timer.connect("timeout", func(): interval.call() ; _cancel_timer(timer))
	
	var dispose = func():
		_cancel_timer(timer)
	
	return CompositeDisposable.new([sad, Disposable.new(dispose)])

func schedule_relative(duetime, action : Callable, state = null) -> DisposableBase:
	var seconds = self.to_seconds(duetime)
	if seconds <= 0.0:
		return self.schedule(action, state)
	
	var sad : SingleAssignmentDisposable = SingleAssignmentDisposable.new()
	
	var interval = func():
		sad.set_disposable(self.invoke_action(action, state))
	
	var timer = GDRx.get_tree().create_timer(seconds)
	timer.connect("timeout", func(): interval.call() ; _cancel_timer(timer))
	
	var dispose = func():
		_cancel_timer(timer)
	
	return CompositeDisposable.new([sad, Disposable.new(dispose)])

func schedule_absolute(duetime, action : Callable, state = null) -> DisposableBase:
	duetime = self.to_seconds(duetime)
	return self.schedule_relative(duetime - self.now(), action, state)

## Utility function to cancel a timer
func _cancel_timer(timer : SceneTreeTimer):
	for conn in timer.timeout.get_connections():
		timer.timeout.disconnect(conn["callable"])
