extends LockBase
class_name RLock

var _aquired_thread
var _counter : int
var _mutex : Mutex

func _init():
	self._aquired_thread = null
	self._counter = 0
	self._mutex = Mutex.new()

func lock():
	var id = OS.get_thread_caller_id()
	self._mutex.lock()
	while self._counter > 0 and self._aquired_thread != id:
		self._mutex.unlock()
		OS.delay_usec((randi() % 10) + 1)
		self._mutex.lock()
	self._aquired_thread = id
	self._counter += 1
	self._mutex.unlock()

func unlock():
	self._mutex.lock()
	if self._counter == 0:
		push_error("RLock has not been aquired by any thread yet!")
		self._mutex.unlock()
		return
	self._counter -= 1
	if self._counter == 0:
		self._aquired_thread = null
	self._mutex.unlock()

func try_lock() -> bool:
	var result : bool
	var id = OS.get_thread_caller_id()
	self._mutex.lock()
	result = self._counter == 0 or self._aquired_thread == id
	self._mutex.unlock()
	return result

func is_locking_thread() -> bool:
	var id = OS.get_thread_caller_id()
	var result : bool
	self._mutex.lock()
	result = self._counter > 0 and self._aquired_thread == id
	self._mutex.unlock()
	return result

# Internal interface to free the lock even though it was aquired more than once
var _saved_recursion_depth : Dictionary

func _unlock_and_store_recursion_depth():
	var id = OS.get_thread_caller_id()
	self._mutex.lock()
	self._saved_recursion_depth[id] = self._counter
	self._counter = 0
	self._aquired_thread = null
	self._mutex.unlock()

func _lock_and_restore_recursion_depth():
	self._mutex.lock()
	self.lock()
	var id = OS.get_thread_caller_id()
	self._counter = self._saved_recursion_depth[id]
	self._aquired_thread = id
	self._mutex.unlock()
