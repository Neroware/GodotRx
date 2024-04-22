## Represents a Godot [Signal] as an observable sequence
static func from_godot_signal_(
	sig : Signal,
	scheduler : SchedulerBase = null
) -> Observable:
	var subscribe = func(
		observer : ObserverBase,
		scheduler_ : SchedulerBase = null
	) -> DisposableBase:
		var _scheduler : SchedulerBase = null
		if scheduler != null: _scheduler = scheduler
		elif scheduler_ != null: _scheduler = scheduler_
		else: _scheduler = GodotSignalScheduler.singleton()
		
		var obj = instance_from_id(sig.get_object_id())
		if obj == null:
			GDRx.raise(NullReferenceError.new())
			return Disposable.new()
		var n_args = -1
		var sig_lst = obj.get_signal_list()
		for dict in sig_lst:
			if dict["name"] == sig.get_name():
				n_args = dict["args"].size()
				break
		
		var action : Callable
		match n_args:
			0:
				action = func():
					observer.on_next(Tuple.new([]))
			1:
				action = func(arg1):
					if arg1 is Array:
						observer.on_next(Tuple.new(arg1))
					else:
						observer.on_next(arg1)
			2:
				action = func(arg1, arg2):
					observer.on_next(Tuple.new([arg1, arg2]))
			3:
				action = func(arg1, arg2, arg3):
					observer.on_next(Tuple.new([arg1, arg2, arg3]))
			4:
				action = func(arg1, arg2, arg3, arg4):
					observer.on_next(Tuple.new([arg1, arg2, arg3, arg4]))
			5:
				action = func(arg1, arg2, arg3, arg4, arg5):
					observer.on_next(Tuple.new([arg1, arg2, arg3, arg4, arg5]))
			6:
				action = func(arg1, arg2, arg3, arg4, arg5, arg6):
					observer.on_next(Tuple.new([arg1, arg2, arg3, arg4, arg5, arg6]))
			7:
				action = func(arg1, arg2, arg3, arg4, arg5, arg6, arg7):
					observer.on_next(Tuple.new([arg1, arg2, arg3, arg4, arg5, arg6, arg7]))
			8:
				action = func(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8):
					observer.on_next(Tuple.new([arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8]))
			_:
				GDRx.raise(TooManyArgumentsError.new(
					"Only up to 8 signal parameters supported! Use lists instead!"))
				return Disposable.new()
		
		if not _scheduler is GodotSignalScheduler:
			_scheduler = GodotSignalScheduler.singleton()
		
		var godot_signal_scheduler : GodotSignalScheduler = _scheduler
		return godot_signal_scheduler.schedule_signal(sig, n_args, action)
	
	return Observable.new(subscribe)
