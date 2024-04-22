extends LockBase
class_name RLock

## Re-entrant lock
## 
## Lock can be aquired multiple times by the same thread

var _aquired_thread
var _counter : int
var _mutex : Mutex

func _init():
	self._aquired_thread = null
	self._counter = 0
	self._mutex = Mutex.new()
	
	self._saved_recursion_depth = -1

func lock():
	self._mutex.lock()
	self._aquired_thread = OS.get_thread_caller_id()
	self._counter += 1

func unlock():
	if self._counter <= 0:
		LockNotAquiredError.new(
			"RLock was released but nobody aquired it!").throw()
		return
	if self._aquired_thread != OS.get_thread_caller_id():
		LockNotAquiredError.new(
			"RLock was released by a thread which has not aquired it!").throw()
		return
	self._counter -= 1
	if self._counter == 0:
		self._aquired_thread = null
	self._mutex.unlock()

func try_lock() -> bool:
	return self._mutex.try_lock()

func is_locking_thread() -> bool:
	var id = OS.get_thread_caller_id()
	return self._aquired_thread == id

## Internal interface to free the lock even though it was aquired more than once
var _saved_recursion_depth : int

## Unlocks the RLock and stores recursion depth
func _unlock_and_store_recursion_depth():
	self._saved_recursion_depth = self._counter
	for __ in range(self._saved_recursion_depth):
		self.unlock()

## Locks the RLock and restores old recursion depth
func _lock_and_restore_recursion_depth():
	for __ in range(self._saved_recursion_depth):
		self.lock()
	self._saved_recursion_depth = -1
