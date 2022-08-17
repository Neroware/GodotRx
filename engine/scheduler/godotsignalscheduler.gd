extends GodotSignalSchedulerBase
class_name GodotSignalScheduler

func _init(verify_ = null):
	if not verify_ == "GDRx":
		push_error("Warning! Must only instance Scheduler from GDRx singleton!")

static func singleton() -> GodotSignalScheduler:
	return GDRx.GodotSignalScheduler_

func schedule_signal(
	conn,
	signal_name : String, 
	n_args : int, 
	action : Callable, 
	state = null
) -> DisposableBase:
	
	var mad : MultipleAssignmentDisposable = MultipleAssignmentDisposable.new()
	
	var signal_callback : Callable
	match n_args:
		0:
			signal_callback = func():
				var action_ = func(scheduler : SchedulerBase, state = null):
					action.call()
				mad.set_disposable(self.invoke_action(action_, state))
		1:
			signal_callback = func(arg1):
				var action_ = func(scheduler : SchedulerBase, state = null):
					action.call(arg1)
				mad.set_disposable(self.invoke_action(action_, state))
		2:
			signal_callback = func(arg1, arg2):
				var action_ = func(scheduler : SchedulerBase, state = null):
					action.call(arg1, arg2)
				mad.set_disposable(self.invoke_action(action_, state))
		3:
			signal_callback = func(arg1, arg2, arg3):
				var action_ = func(scheduler : SchedulerBase, state = null):
					action.call(arg1, arg2, arg3)
				mad.set_disposable(self.invoke_action(action_, state))
		4:
			signal_callback = func(arg1, arg2, arg3, arg4):
				var action_ = func(scheduler : SchedulerBase, state = null):
					action.call(arg1, arg2, arg3, arg4)
				mad.set_disposable(self.invoke_action(action_, state))
		5:
			signal_callback = func(arg1, arg2, arg3, arg4, arg5):
				var action_ = func(scheduler : SchedulerBase, state = null):
					action.call(arg1, arg2, arg3, arg4, arg5)
				mad.set_disposable(self.invoke_action(action_, state))
		6:
			signal_callback = func(arg1, arg2, arg3, arg4, arg5, arg6):
				var action_ = func(scheduler : SchedulerBase, state = null):
					action.call(arg1, arg2, arg3, arg4, arg5, arg6)
				mad.set_disposable(self.invoke_action(action_, state))
		7:
			signal_callback = func(arg1, arg2, arg3, arg4, arg5, arg6, arg7):
				var action_ = func(scheduler : SchedulerBase, state = null):
					action.call(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
				mad.set_disposable(self.invoke_action(action_, state))
		8:
			signal_callback = func(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8):
				var action_ = func(scheduler : SchedulerBase, state = null):
					action.call(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
				mad.set_disposable(self.invoke_action(action_, state))
		_:
			push_error("Only up to 8 signal parameters supported! Use lists instead!")
			return null
	
	var dispose = func():
		conn.disconnect(signal_name, signal_callback)
	
	conn.connect(signal_name, signal_callback)
	return CompositeDisposable.new([mad, Disposable.new(dispose)])
