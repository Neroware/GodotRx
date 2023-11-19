extends Scheduler
class_name TrampolineScheduler

## Represents an object that schedules units of work on the [Trampoline].
## 
## You should never schedule timeouts using the [TrampolineScheduler], as
## it will block the thread while waiting.
##
## Each instance has its own trampoline (and queue), and you can schedule work
## on it from different threads. Beware though, that the first thread to call
## a [code]schedule[/code] method while the trampoline is idle will then remain occupied
## until the queue is empty.

var _tramp : Trampoline

func _init():
	self._tramp = Trampoline.new()

## Returns the [Trampoline]
func get_trampoline() -> Trampoline:
	return self._tramp

## Schedules an action to be executed.
## [br]
## [b]Args:[/b]
## [br]
##    [code]action[/code] Action to be executed.
## [br]
##    [code]state[/code] [Optional] state to be given to the action function.
## [br][br]
## [b]Returns:[/b]
## [br]
##    The disposable object used to cancel the scheduled action
##    (best effort).
func schedule(action : Callable, state = null) -> DisposableBase:
	return self.schedule_absolute(self.now(), action, state)

## Schedules an action to be executed after duetime.
## [br]
## [b]Args:[/b]
## [br]
##    [code]duetime[/code] Relative time after which to execute the action.
## [br]
##    [code]action[/code] Action to be executed.
## [br]
##    [code]state[/code] [Optional] state to be given to the action function.
## [br][br]
## 
## [b]Returns:[/b]
## [br]
##    The disposable object used to cancel the scheduled action
##    (best effort).
func schedule_relative(duetime, action : Callable, state = null) -> DisposableBase:
	duetime = max(DELTA_ZERO, duetime)
	return self.schedule_absolute(self.now() + duetime, action, state)

## Schedules an action to be executed at duetime.
## [br]
## [b]Args:[/b]
## [br]
##    [code]duetime[/code] Absolute time at which to execute the action.
## [br]
##    [code]action[/code] Action to be executed.
## [br]
##    [code]state[/code] [Optional] state to be given to the action function.
## [br][br]
## 
## [b]Returns:[/b]
## [br]
##    The disposable object used to cancel the scheduled action
##    (best effort).
func schedule_absolute(duetime, action : Callable, state = null) -> DisposableBase:
	var dt : float = duetime
	if dt > self.now():
		push_warning("Do not schedule blocking work!")
	var item : ScheduledItem = ScheduledItem.new(self, dt, state, action)
	
	self.get_trampoline().run(item)
	
	return item.disposable

## Test if scheduling is required.
## 
## Gets a value indicating whether the caller must call a
## schedule method. If the [Trampoline] is active, then it returns
## [code]false[/code]; otherwise, if the trampoline is not active, then it
## returns [code]true[/code].
func schedule_required() -> bool:
	return self.get_trampoline().idle()

## Method for testing the [TrampolineScheduler].
func ensure_trampoline(action : Callable):
	if self.schedule_required():
		return self.schedule(action)
	return action.call(self, null)
