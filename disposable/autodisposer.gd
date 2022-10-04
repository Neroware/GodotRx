class_name AutoDisposer

## Automatically disposes a [DisposableBase] when the [Object] is deleted.

var _disp : DisposableBase

func _init(disp : DisposableBase):
	self._disp = disp

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		_disp.dispose()

static func Add(obj : Object, disp : DisposableBase) -> AutoDisposer:
	var auto_disposer : AutoDisposer = AutoDisposer.new(disp)
	var id = disp.get_instance_id()
	var meta_entry = "dispose_with_" + (str(id) if id > 0 else "neg" + str(abs(id)))
	obj.set_meta(meta_entry, auto_disposer)
	return auto_disposer
