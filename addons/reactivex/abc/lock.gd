class_name LockBase

## Interface of a Lock
## 
## Allows a thread to aquire and release it.

func lock():
	NotImplementedError.raise()

func unlock():
	NotImplementedError.raise()

func try_lock() -> bool:
	NotImplementedError.raise()
	return false

func is_locking_thread() -> bool:
	NotImplementedError.raise()
	return false

func _unlock_and_store_recursion_depth():
	NotImplementedError.raise()

func _lock_and_restore_recursion_depth():
	NotImplementedError.raise()
