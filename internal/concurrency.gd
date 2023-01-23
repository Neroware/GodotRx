## Links the [Thread] instance to a [Callable] before starting it.
class StartableThread extends StartableBase:
	var _thread : Thread
	var _target : Callable
	var _priority : int
	var _started : bool
	
	func _init(target : Callable, priority = Thread.PRIORITY_NORMAL):
		self._thread = Thread.new()
		self._target = target
		self._priority = priority
		self._started = false
	
	var thread : Thread:
		get: return self._thread
	
	func start():
		if self._started:
			GDRx.raise_message("Thread already started!")
			return
		
		var action = func():
			GDRx.register_thread(self._thread)
			self._target.call()
			self._thread = null
			self._target = GDRx.basic.noop
		
		self._started = true
		self._thread.start(action, self._priority)

func default_thread_factory(target : Callable) -> StartableThread:
	return StartableThread.new(target)

## Operator to synchronize access to a given function
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
				GDRx.exc.TooManyArgumentsException.new(
					"synchronized-wrapper only supports up to 4 parameters. Returning noop!"
				).throw()
				inner = func(): return
		
		return inner
	
	return wrapper

func with(l, fun : Callable = GDRx.basic.noop):
	var ret = null
	if l.has_method("lock"):
		l.lock()
	ret = fun.call()
	if l.has_method("unlock"):
		l.unlock()
	return ret
