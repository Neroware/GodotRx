extends GodotSignalSchedulerBase
class_name GodotSignalScheduler

func _init(verify_ = null):
	if not verify_ == "GDRx":
		push_warning("Warning! Must only instance Scheduler from GDRx singleton!")

static func singleton() -> GodotSignalScheduler:
	return GDRx.GodotSignalScheduler_

func schedule_signal(
	sig : Signal,
	n_args : int, 
	action : Callable, 
	state = null
) -> DisposableBase:
	
	var disp : Disposable = Disposable.new()
	
	var signal_callback : Callable
	match n_args:
		0:
			signal_callback = func():
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call()
				disp = self.invoke_action(action_, state)
		1:
			signal_callback = func(arg1):
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call(arg1)
				disp = self.invoke_action(action_, state)
		2:
			signal_callback = func(arg1, arg2):
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call(arg1, arg2)
				disp = self.invoke_action(action_, state)
		3:
			signal_callback = func(arg1, arg2, arg3):
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call(arg1, arg2, arg3)
				disp = self.invoke_action(action_, state)
		4:
			signal_callback = func(arg1, arg2, arg3, arg4):
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call(arg1, arg2, arg3, arg4)
				disp = self.invoke_action(action_, state)
		5:
			signal_callback = func(arg1, arg2, arg3, arg4, arg5):
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call(arg1, arg2, arg3, arg4, arg5)
				disp = self.invoke_action(action_, state)
		6:
			signal_callback = func(arg1, arg2, arg3, arg4, arg5, arg6):
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call(arg1, arg2, arg3, arg4, arg5, arg6)
				disp = self.invoke_action(action_, state)
		7:
			signal_callback = func(arg1, arg2, arg3, arg4, arg5, arg6, arg7):
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
				disp = self.invoke_action(action_, state)
		8:
			signal_callback = func(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8):
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
				disp = self.invoke_action(action_, state)
		_:
			GDRx.raise(GDRx.exc.TooManyArgumentsException.new(
				"Only up to 8 signal parameters supported! Use lists instead!"))
			return null
	
	var obj = instance_from_id(sig.get_object_id())
	
	var dispose = func():
		if obj != null:
			sig.disconnect(signal_callback)
	
	sig.connect(signal_callback)
	
	var cd : CompositeDisposable = CompositeDisposable.new([disp, Disposable.new(dispose)])
	AutoDisposer.Add(obj, cd)
	return cd
