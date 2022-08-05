extends ScheduledObserver
class_name ObserveOnObserver

func _on_next_core(i):
	super._on_next_core(i)
	self.ensure_active()

func _on_error_core(e):
	super._on_error_core(e)
	self.ensure_active()

func _on_completed_core():
	super._on_completed_core()
	self.ensure_active()
