class_name __GDRx_Engine__

### ======================================================================= ###
#   Observables
### ======================================================================= ###
var _GodotSignal_ = load("res://reactivex/engine/observable/godotsignal.gd")
var _GodotLifecycle_ = load("res://reactivex/engine/observable/godotnodelifecycle.gd")

func from_godot_signal(conn, signal_name : String, n_args : int, scheduler : SchedulerBase = null) -> Observable:
	return _GodotSignal_.from_godot_signal_(conn, signal_name, n_args, scheduler)

func from_godot_node_lifecycle_event(conn : Node, type : int) -> Observable:
	return _GodotLifecycle_.from_godot_node_lifecycle_event_(conn, type)
