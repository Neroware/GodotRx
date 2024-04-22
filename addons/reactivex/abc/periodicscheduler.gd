extends SchedulerBase
class_name PeriodicSchedulerBase

## A scheduler for periodic actions
## 
## Periodically schedules actions for repeated future execution.

## Schedule a periodic action for repeated execution every time
## [code]period[/code] seconds have expired.
func schedule_periodic(
	_period : float,
	_action : Callable,
	_state = null) -> DisposableBase:
		NotImplementedError.raise()
		return null
