extends SchedulerBase
class_name Scheduler

const UTC_ZERO = 0 # Yep, zero
const DELTA_ZERO = 0

func now() -> float:
	return self.to_seconds(GDRx.basic.default_now())

func invoke_action(action : Callable, state = null) -> DisposableBase:
	var ret = action.call(self, state)
	if ret is DisposableBase:
		return ret
	return Disposable.new()

static func to_seconds(value):
	if value is float:
		return value
	if not value is Dictionary:
		push_error("Error: Cannot convert datetime from any other class than Dictionary!")
		return 0
	var datetime : Dictionary = value
	return Time.get_unix_time_from_datetime_dict(datetime)
