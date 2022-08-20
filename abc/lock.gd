class_name LockBase

## Interface of a Lock
##
## Allows a thread to aquire and release it.

func lock():
	push_error("Not implemented here!")

func unlock():
	push_error("Not implemented here!")

func try_lock() -> bool:
	push_error("Not implemented here!")
	return false

func is_locking_thread() -> bool:
	push_error("Not implemented here!")
	return false

func _unlock_and_store_recursion_depth():
	push_error("Not implemented here!")

func _lock_and_restore_recursion_depth():
	push_error("Not implemented here!")
