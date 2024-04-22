extends Scheduler
class_name ImmediateScheduler

## Represents an object that schedules units of work to run immediately
## on the current thread. 
## 
## You're not allowed to schedule timeouts using the
## [ImmediateScheduler] since that will block the current thread while waiting.
## Attempts to do so will raise a [WouldBlockError]

func _init(verify_ = null):
	if not verify_ == "GDRx":
		push_warning("Warning! Must only instance Scheduler from GDRx singleton!")

static func singleton() -> ImmediateScheduler:
	return GDRx.ImmediateScheduler_

func schedule(action : Callable, state = null) -> DisposableBase:
	return self.invoke_action(action, state)

func schedule_relative(duetime, action : Callable, state = null) -> DisposableBase:
	if duetime > DELTA_ZERO:
		WouldBlockError.raise()
		return Disposable.new()
	return self.invoke_action(action, state)

func schedule_absolute(duetime, action : Callable, state = null) -> DisposableBase:
	return self.schedule_relative(duetime - self.now(), action, state)
