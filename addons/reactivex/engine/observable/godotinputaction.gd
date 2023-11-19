enum EInputState 
{
	RELEASED = 0, JUST_PRESSED = 1, PRESSED = 2, JUST_RELEASED = 3
}

## Represents an input action as an observable sequence which emits input state
## each time [code]checks[/code] emits an item.
static func from_godot_input_action_(input_action : String, checks : Observable) -> Observable:
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		
		var prev_pressed = RefValue.Set(false)
		var curr_pressed = RefValue.Set(false)
		
		var on_next = func(__):
			prev_pressed.v = curr_pressed.v
			curr_pressed.v = Input.is_action_pressed(input_action)
			if prev_pressed.v != curr_pressed.v:
				observer.on_next(EInputState.JUST_PRESSED if curr_pressed.v else EInputState.JUST_RELEASED)
			observer.on_next(EInputState.PRESSED if curr_pressed.v else EInputState.RELEASED)
		
		return checks.subscribe(
			on_next, observer.on_error, observer.on_completed,
			scheduler
		)
	
	return Observable.new(subscribe)
