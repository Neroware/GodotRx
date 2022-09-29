class_name ConditionalVariable

## Naive implementation of a conditional variable for multi-threading

var _lock
var _waiting_queue : Array

func _init(lock_ = null):
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
	for __ in range(n): self._waiting_queue.pop_front()

func notify_all():
	if not self._lock.is_locking_thread():
		GDRx.exc.LockNotAquiredException.new().throw()
		return
	self._waiting_queue.clear()

func wait(time_sec : float = -1.0) -> bool:
	if not self._lock.is_locking_thread():
		GDRx.exc.LockNotAquiredException.new().throw()
		return false
	var id = OS.get_thread_caller_id()
	
	var timeout_ = RefValue.Set(false)
	if time_sec >= 0.0:
		var timer = GDRx.get_tree().create_timer(time_sec)
		timer.connect("timeout", func():
			timeout_.v = true
			for conn in timer.timeout.get_connections():
				timer.timeout.disconnect(conn["callable"])
		)
	
	if id in self._waiting_queue:
		push_warning("Warning! Multiple wait-calls present for single thread!")
	self._waiting_queue.push_back(id)
	
	while id in self._waiting_queue and not timeout_.v:
		self._lock._unlock_and_store_recursion_depth()
		OS.delay_usec((randi() % 10) + 1)
		self._lock._lock_and_restore_recursion_depth()
	
	return not timeout_.v
