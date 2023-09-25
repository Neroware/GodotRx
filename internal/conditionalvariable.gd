class_name ConditionalVariable

## Naive implementation of a conditional variable for multi-threading
var _mutex : Mutex
var _waiting_queue : Array[Lock]

func _init():
	self._mutex = Mutex.new()
	self._waiting_queue = []

func wait(lock : LockBase):
	var thread_lock : Lock = Lock.new()
	thread_lock.lock()
	
	self._mutex.lock()
	self._waiting_queue.push_back(thread_lock)
	self._mutex.unlock()
	
	lock._unlock_and_store_recursion_depth()
	thread_lock.lock()
	lock._lock_and_restore_recursion_depth()
	
	thread_lock.unlock()

func wait_pred(lock : LockBase, stop_waiting : Callable):
	while !stop_waiting.call():
		self.wait(lock)

func wait_for(lock : LockBase, time_sec : float) -> bool:
	var thread_lock : Lock = Lock.new()
	thread_lock.lock()
	
	self._mutex.lock()
	self._waiting_queue.push_back(thread_lock)
	self._mutex.unlock()
	
	var notified = RefValue.Set(true)
	var on_timeout = func():
		notified.v = false
		thread_lock.unlock()
		self._mutex.lock()
		self._waiting_queue.erase(thread_lock)
		self._mutex.unlock()
	
	var timer = GDRx.get_tree().create_timer(time_sec)
	timer.connect("timeout", on_timeout)
	
	lock._unlock_and_store_recursion_depth()
	thread_lock.lock()
	lock._lock_and_restore_recursion_depth()
	
	if notified.v:
		timer.disconnect("timeout", on_timeout)
	
	thread_lock.unlock()
	return notified.v

func notify(n = 1):
	self._mutex.lock()
	for __ in range(n):
		if self._waiting_queue.is_empty():
			break
		var next : Lock = self._waiting_queue.pop_front()
		next.unlock()
	self._mutex.unlock()

func notify_all():
	self._mutex.lock()
	while not self._waiting_queue.is_empty():
		var next : Lock = self._waiting_queue.pop_front()
		next.unlock()
	self._mutex.unlock()
