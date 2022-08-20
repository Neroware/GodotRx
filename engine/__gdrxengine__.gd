class_name __GDRx_Engine__
## Provides access to Godot-specific [Observable] constructors.
##
## Bridge between Godot-specific implementations and [__GDRx_Singleton__]

# =========================================================================== #
#   Observables
# =========================================================================== #
var _GodotSignal_ = load("res://reactivex/engine/observable/godotsignal.gd")
var _GodotLifecycle_ = load("res://reactivex/engine/observable/godotnodelifecycle.gd")
var _GodotInputAction_ = load("res://reactivex/engine/observable/godotinputaction.gd")

func from_godot_signal(conn : Object, signal_name : String, n_args : int, scheduler : SchedulerBase = null) -> Observable:
	return _GodotSignal_.from_godot_signal_(conn, signal_name, n_args, scheduler)

func from_godot_node_lifecycle_event(conn : Node, type : int) -> Observable:
	return _GodotLifecycle_.from_godot_node_lifecycle_event_(conn, type)

func from_godot_input_action(input_action : String, checks : Observable) -> Observable:
	return _GodotInputAction_.from_godot_input_action_(input_action, checks)
