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
	obj.set_meta("dispose_with", auto_disposer)
	return auto_disposer
