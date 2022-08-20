class _NodeLifecycleListener extends Node:
	signal _on_event(data)

class _ListenerOnProcess extends _NodeLifecycleListener:
	func _process(delta : float):
		_on_event.emit(delta)

class _ListenerOnPhysicsProcess extends _NodeLifecycleListener:
	func _physics_process(delta : float):
		_on_event.emit(delta)

class _ListenerOnInput extends _NodeLifecycleListener:
	func _input(event : InputEvent):
		_on_event.emit(event)

class _ListenerOnShortcutInput extends _NodeLifecycleListener:
	func _shortcut_input(event : InputEvent):
		_on_event.emit(event)

class _ListenerOnUnhandledInput extends _NodeLifecycleListener:
	func _unhandled_input(event : InputEvent):
		_on_event.emit(event)

class _ListenerOnUnhandledKeyInput extends _NodeLifecycleListener:
	func _unhandled_key_input(event : InputEvent):
		_on_event.emit(event)

## Represents [Node] lifecycle events like [code]_process(delta)[/code]. 
## Observable emits argument from call as item on the stream.
## [br][br]
## [color=yellow]Warning![/color] This only creates a Node of type [b]_Listener[/b]
## which is added as a child since it is not possible to get signals on lifecycle callbacks.
static func from_godot_node_lifecycle_event_(conn : Node, type : int) -> Observable:
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		var _listener : _NodeLifecycleListener
		match type:
			0:
				_listener = _ListenerOnProcess.new()
			1:
				_listener = _ListenerOnPhysicsProcess.new()
			2:
				_listener = _ListenerOnInput.new()
			3:
				_listener = _ListenerOnShortcutInput.new()
			4:
				_listener = _ListenerOnUnhandledInput.new()
			5:
				_listener = _ListenerOnUnhandledKeyInput.new()
		_listener.name = "__" + str(conn.name) + "$listener__"
		conn.call_deferred("add_child", _listener)
		
		var dispose = func():
			_listener.queue_free()
		
		var subscription = GDRx.gd.from_godot_signal(_listener, "_on_event", 1).subscribe(
			observer, func(e):return, func():return,
			scheduler
		)
		var disp = Disposable.new(dispose)
		return CompositeDisposable.new([subscription, disp])
	
	return Observable.new(subscribe)
