class_name AutoDisposer

## Links a [DisposableBase] to an [Object]'s lifetime.

var _disp : DisposableBase

func _init(disp : DisposableBase):
	self._disp = disp

static func add(obj : Object, disp : DisposableBase) -> AutoDisposer:
	var auto_disposer : AutoDisposer = AutoDisposer.new(disp)
	var id = disp.get_instance_id()
	var meta_entry = "autodispose_" + (str(id) if id > 0 else "neg" + str(abs(id)))
	obj.set_meta(meta_entry, auto_disposer)
	return auto_disposer

static func remove(obj : Object, disp : DisposableBase):
	var id = disp.get_instance_id()
	var meta_entry = "autodispose_" + (str(id) if id > 0 else "neg" + str(abs(id)))
	obj.remove_meta(meta_entry)

static func remove_and_dispose(obj : Object, disp : DisposableBase):
	remove(obj, disp)
	disp.dispose()

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		self._disp.dispose()
