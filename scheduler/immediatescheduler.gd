extends Scheduler
class_name ImmediateScheduler


func _init(verify_ = null):
	if not verify_ == "GDRx":
		push_error("Warning! Must only instance Scheduler from GDRx singleton!")

static func singleton() -> ImmediateScheduler:
	return GDRx.ImmediateScheduler_

func schedule(action : Callable, state = null) -> DisposableBase:
	return self.invoke_action(action, state)

func schedule_relative(duetime, action : Callable, state = null) -> DisposableBase:
	duetime = to_seconds(duetime)
	if duetime > DELTA_ZERO:
		push_error(GDRx.error.WouldBlockException.new())
	return self.invoke_action(action, state)

func schedule_absolute(duetime, action : Callable, state = null) -> DisposableBase:
	duetime = to_seconds(duetime)
	return self.schedule_relative(duetime - self.now(), action, state)
