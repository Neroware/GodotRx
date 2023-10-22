class_name AutoDisposer

## Links a [DisposableBase] to an [Object]'s lifetime.

var _disp : DisposableBase

func _init(disp : DisposableBase):
	self._disp = disp

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		self._disp.dispose()

static func _meta_key(obj : Object, disp : DisposableBase):
	var disp_id : int = disp.get_instance_id()
	var obj_id : int = obj.get_instance_id()
	var meta_entry = "autodispose_" + \
		("0" if disp_id > 0 else "1") + \
		("0" if obj_id > 0 else "1") + \
		"_d" + str(abs(disp_id)) + "_o" + str(abs(obj_id))
	return meta_entry

static func _collect_garbage(obj : Object):
	for meta_key in obj.get_meta_list():
		var meta_entry = obj.get_meta(meta_key)
		if meta_entry is AutoDisposer:
			if meta_entry._disp.get("is_disposed"):
				obj.remove_meta(meta_entry)

static func add(obj : Object, disp : DisposableBase) -> AutoDisposer:
	AutoDisposer._collect_garbage(obj)
	var auto_disposer : AutoDisposer = AutoDisposer.new(disp)
	var meta_key = AutoDisposer._meta_key(obj, disp)
	obj.set_meta(meta_key, auto_disposer)
	return auto_disposer

static func remove(obj : Object, disp : DisposableBase):
	var meta_key = AutoDisposer._meta_key(obj, disp)
	obj.remove_meta(meta_key)

static func remove_and_dispose(obj : Object, disp : DisposableBase):
	AutoDisposer.remove(obj, disp)
	disp.dispose()
