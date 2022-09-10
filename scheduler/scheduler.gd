extends SchedulerBase
class_name Scheduler

## Base class for the various scheduler implementations in this package as
##    This does not include an implementation of [method PeriodicSchedulerBase.schedule_periodic], 
##    refer to [PeriodicScheduler].

const UTC_ZERO = 0
const DELTA_ZERO = 0

## Represents a notion of time for this scheduler. Tasks being
##        scheduled on a scheduler will adhere to the time denoted by this
##        property.
## [br]
##        [b]Returns:[/b]
## [br]
##             The scheduler's current time, as a datetime instance.
func now() -> float:
	return self.to_seconds(GDRx.basic.default_now())

## Invoke the given given action. This is typically called by instances
##        of [ScheduledItem].
## [br]
##        [b]Args:[/b]
## [br]
##            [code]action[/code] Action to be executed.
## [br]
##            [code]state[/code] [Optional] state to be given to the action function.
## [br][br]
##
##        [b]Returns:[/b]
## [br]
##            The disposable object returned by the action, if any; or a new
##            (no-op) disposable otherwise.
func invoke_action(action : Callable, state = null) -> DisposableBase:
	var ret = action.call(self, state)
	if ret is DisposableBase:
		return ret
	return Disposable.new()

## Converts a timestamp dictionary to Unix-time in seconds.
static func to_seconds(value):
	if value is float:
		return value
	if not value is Dictionary:
		push_error("Error: Cannot convert datetime from any other class than Dictionary!")
		return 0
	var datetime : Dictionary = value
	return Time.get_unix_time_from_datetime_dict(datetime)
