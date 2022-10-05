class_name ConditionalVariable

## Naive implementation of a conditional variable for multi-threading

var _lock : LockBase
var _waiting_queue : Array[Lock]

func _init(lock_ : LockBase = null):
	self._lock = lock_ if lock_ != null else RLock.new()
	self._waiting_queue = []

func lock():
	self._lock.lock()

func unlock():
	self._lock.unlock()

func notify(n = 1):
	if not self._lock.is_locking_thread():
		GDRx.exc.LockNotAquiredException.new().throw()
		return
	for __ in range(n):
		if self._waiting_queue.is_empty():
			break
		var next : Lock = self._waiting_queue.pop_front()
		next.unlock()

func notify_all():
	if not self._lock.is_locking_thread():
		GDRx.exc.LockNotAquiredException.new().throw()
		return
	while not self._waiting_queue.is_empty():
		var next : Lock = self._waiting_queue.pop_front()
		next.unlock()

func wait(time_sec = null) -> bool:
	if not self._lock.is_locking_thread():
		GDRx.exc.LockNotAquiredException.new().throw()
		return false
	
	var thread_lock : Lock = Lock.new()
	thread_lock.lock()
	self._waiting_queue.push_back(thread_lock)
	
	var notified = RefValue.Set(true)
	
	if time_sec != null:
		var time_sec_ : float = time_sec
		var timeout_interval = func():
			OS.delay_msec((1000.0 * time_sec_) as int)
			self._lock.lock()
			if thread_lock in self._waiting_queue:
				thread_lock.unlock()
				self._waiting_queue.erase(thread_lock)
				notified.v = false
			self._lock.unlock()
		var timeout_thread = GDRx.concur.StartableThread.new(timeout_interval)
		timeout_thread.start()
	
	self._lock._unlock_and_store_recursion_depth()
	thread_lock.lock()
	self._lock._lock_and_restore_recursion_depth()
	
	return notified.v
