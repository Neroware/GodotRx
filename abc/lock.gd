class_name LockBase

## Interface of a Lock
##
## Allows a thread to aquire and release it.

func lock():
	GDRx.raise(GDRx.exc.NotImplementedException.new())

func unlock():
	GDRx.raise(GDRx.exc.NotImplementedException.new())

func try_lock() -> bool:
	GDRx.raise(GDRx.exc.NotImplementedException.new())
	return false

func is_locking_thread() -> bool:
	GDRx.raise(GDRx.exc.NotImplementedException.new())
	return false

func _unlock_and_store_recursion_depth():
	GDRx.raise(GDRx.exc.NotImplementedException.new())

func _lock_and_restore_recursion_depth():
	GDRx.raise(GDRx.exc.NotImplementedException.new())
