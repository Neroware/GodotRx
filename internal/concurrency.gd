class StartableThread:
	var _thread : Thread
	var _target : Callable
	
	func _init(target : Callable):
		self._thread = Thread.new()
		self._target = target
	
	func thread() -> Thread:
		return self._thread
	
	func start(priority = Thread.PRIORITY_NORMAL):
		self._thread.start(self._target, priority)

func default_thread_factory(target : Callable) -> StartableThread:
	return StartableThread.new(target)

func synchronized(lock : RLock, n_args : int) -> Callable:
	var wrapper = func(fn : Callable) -> Callable:
		var inner : Callable
		match n_args:
			0:
				inner = func():
					lock.lock()
					var r = fn.call()
					lock.unlock()
					return r
			1:
				inner = func(arg0):
					lock.lock()
					var r = fn.call(arg0)
					lock.unlock()
					return r
			2:
				inner = func(arg0, arg1):
					lock.lock()
					var r = fn.call(arg0, arg1)
					lock.unlock()
					return r
			3:
				inner = func(arg0, arg1, arg2):
					lock.lock()
					var r = fn.call(arg0, arg1, arg2)
					lock.unlock()
					return r
			4:
				inner = func(arg0, arg1, arg2, arg3):
					lock.lock()
					var r = fn.call(arg0, arg1, arg2, arg3)
					lock.unlock()
					return r
			_:
				push_error("synchronized-wrapper only supports up to 4 parameters. Returning noop!")
				inner = func(): return
		
		return inner
	
	return wrapper
