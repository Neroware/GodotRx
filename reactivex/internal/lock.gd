extends LockBase
class_name Lock

var _aquired_thread
var _mutex : Mutex

func _init():
	self._aquired_thread = null
	self._mutex = Mutex.new()

func lock():
	self._mutex.lock()
	while self._aquired_thread != null:
		self._mutex.unlock()
		OS.delay_usec((randi() % 10) + 1)
		self._mutex.lock()
	self._aquired_thread = OS.get_thread_caller_id()
	self._mutex.unlock()

func unlock():
	self._mutex.lock()
	if self._aquired_thread == null:
		push_error("Lock was released but nobody aquired it!")
	self._aquired_thread = null
	self._mutex.unlock()

func try_lock() -> bool:
	var result : bool
	self._mutex.lock()
	result = self._aquired_thread == null
	self._mutex.unlock()
	return result

func is_locking_thread() -> bool:
	var result : bool
	self._mutex.lock()
	result = OS.get_thread_caller_id() == self._aquired_thread
	self._mutex.unlock()
	return result

func _unlock_and_store_recursion_depth():
	self.unlock()

func _lock_and_restore_recursion_depth():
	self.lock()
