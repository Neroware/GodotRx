extends Scheduler
class_name TrampolineScheduler


var _tramp : Trampoline

func _init():
	self._tramp = Trampoline.new()

func get_trampoline() -> Trampoline:
	return self._tramp

func schedule(action : Callable, state = null) -> DisposableBase:
	return self.schedule_absolute(self.now(), action, state)

func schedule_relative(duetime, action : Callable, state = null) -> DisposableBase:
	duetime = max(DELTA_ZERO, to_seconds(duetime))
	return self.schedule_absolute(self.now() + duetime, action, state)

func schedule_absolute(duetime, action : Callable, state = null) -> DisposableBase:
	var dt = self.to_seconds(duetime)
	if dt > self.now():
		push_warning("Do not schedule blocking work!")
	var item : ScheduledItem = ScheduledItem.new(self, dt, state, action)
	
	self.get_trampoline().run(item)
	
	return item._disposable

func schedule_required() -> bool:
	return self.get_trampoline().idle()

func ensure_trampoline(action : Callable):
	if self.schedule_required():
		return self.schedule(action)
	return action.call(self, null)
