class_name SchedulerBase

### IMPORTANT! We will always use DateTime/DeltaTime in Seconds!
### Represented as floats because otherwise I'll go nutso!

func now() -> float:
	push_error("No implementation here!")
	return -1.0

func schedule(action : Callable, state = null) -> DisposableBase:
	push_error("No implementation here!")
	return null

func schedule_relative(duetime, action : Callable, state = null) -> DisposableBase:
	push_error("No implementation here!")
	return null

func schedule_absolute(duetime, action : Callable, state = null) -> DisposableBase:
	push_error("No implementation here!")
	return null

static func to_seconds(datetime : Dictionary) -> float:
	push_error("No implementation here!")
	return -1.0
