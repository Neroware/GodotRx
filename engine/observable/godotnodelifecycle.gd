class _NodeLifecycleListener extends Node:
	signal on_event(data)

class _ListenerOnProcess extends _NodeLifecycleListener:
	func _process(delta : float):
		on_event.emit(delta)

class _ListenerOnPhysicsProcess extends _NodeLifecycleListener:
	func _physics_process(delta : float):
		on_event.emit(delta)

class _ListenerOnInput extends _NodeLifecycleListener:
	func _input(event : InputEvent):
		on_event.emit(event)

class _ListenerOnShortcutInput extends _NodeLifecycleListener:
	func _shortcut_input(event : InputEvent):
		on_event.emit(event)

class _ListenerOnUnhandledInput extends _NodeLifecycleListener:
	func _unhandled_input(event : InputEvent):
		on_event.emit(event)

class _ListenerOnUnhandledKeyInput extends _NodeLifecycleListener:
	func _unhandled_key_input(event : InputEvent):
		on_event.emit(event)

## Represents [Node] lifecycle events like [method Node._process].
## Observable emits argument from call as item on the stream.
## [br][br]
## [color=yellow]Warning![/color] This only creates a Node of type [b]_NodeLifecycleListener[/b]
## which is added as a child since it is not possible to get signals on lifecycle callbacks.
static func from_godot_node_lifecycle_event_(conn : Node, type : int) -> Observable:
	var listener : _NodeLifecycleListener = null
	var count : RefValue = RefValue.Set(0)
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		if count.v == 0:
			match type:
				0:
					listener = _ListenerOnProcess.new()
				1:
					listener = _ListenerOnPhysicsProcess.new()
				2:
					listener = _ListenerOnInput.new()
				3:
					listener = _ListenerOnShortcutInput.new()
				4:
					listener = _ListenerOnUnhandledInput.new()
				5:
					listener = _ListenerOnUnhandledKeyInput.new()
			listener.name = "_GDRxListener" + str(conn.get_instance_id())
			conn.call_deferred("add_child", listener)
		count.v += 1
		
		var dispose = func():
			count.v -= 1
			if count.v == 0:
				listener.queue_free()
		
		var subscription = GDRx.gd.from_godot_signal(listener.on_event).subscribe(
			observer, func(e):return, func():return,
			scheduler
		)
		var disp = Disposable.new(dispose)
		return CompositeDisposable.new([subscription, disp])
	
	return Observable.new(subscribe)
