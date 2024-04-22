extends LockBase
class_name Lock

## A lock which can only be aquired and released once by any thread.

var _aquired_thread
var _semaphore : Semaphore

func _init():
	self._aquired_thread = null
	self._semaphore = Semaphore.new()
	self._semaphore.post()

func lock():
	self._semaphore.wait()
	self._aquired_thread = OS.get_thread_caller_id()

func unlock():
	if self._aquired_thread == null:
		LockNotAquiredError.new(
			"Lock was released but nobody aquired it!").throw()
		return
	self._aquired_thread = null
	self._semaphore.post()

func try_lock() -> bool:
	return self._semaphore.try_wait()

func is_locking_thread() -> bool:
	var id = OS.get_thread_caller_id()
	return self._aquired_thread == id

func _unlock_and_store_recursion_depth():
	self.unlock()

func _lock_and_restore_recursion_depth():
	self.lock()
