extends Scheduler
class_name PeriodicSchedulerBase

## A scheduler for periodic actions
##
## Periodically schedules actions for repeated future execution.

## Schedule a periodic action for repeated execution every time
## [code]period[/code] seconds have expired.
func schedule_periodic(
	period : float,
	action : Callable,
	state = null) -> DisposableBase:
		GDRx.exc.NotImplementedException.Throw()
		return null
