class ThreadManager extends Object:
	
	var _thread_registry_lock : ReadWriteLock
	var _thread_registry_dict : Dictionary
	var _thread_registry : Tuple
	
	var _mutex : RLock = RLock.new()
	var _cond : ConditionalVariable = ConditionalVariable.new()
	var _cleanup_thread : Thread = Thread.new()
	var _shutdown : bool = false
	var _finished_threads : Array[StartableBase]
	
	var THREAD_REGISTRY : Tuple:
		get: return self._thread_registry
	
	func _init():
		self._thread_registry_lock = ReadWriteLock.new()
		self._thread_registry_dict = {}
		self._thread_registry = Tuple.new([
			self._thread_registry_lock,
			self._thread_registry_dict
		])
		
		self._cleanup_thread.start(self._cleanup)
	
	func stop_and_join():
		self._mutex.lock()
		self._shutdown = true
		self._mutex.unlock()
		
		self._cond.notify_all()
		self._cleanup_thread.wait_to_finish()
		
		if not self._finished_threads.is_empty():
			assert(false and "should not happen!".length())
	
	## This method adds the thread object to the cleanup thread
	## allowing it to be joined and disposed properly.
	## 
	## This is mainly done due to Godot's [method Thread.wait_to_finish] shinanigans.
	func finish(thread : StartableBase):
		var __ = LockGuard.new(self._mutex)
		self._finished_threads.push_back(thread)
		self._cond.notify_all()
	
	func _cleanup():
		while true:
			var thread : StartableBase = null
			if true:
				var __ = LockGuard.new(self._mutex)
				self._cond.wait_pred(self._mutex, func(): 
					return self._shutdown or !self._finished_threads.is_empty())
				
				if (self._shutdown):
					break
				
				thread = self._finished_threads.back()
				self._finished_threads.pop_back()
			
			thread.wait_to_finish()


## Links the [Thread] instance to a [Callable] before starting it.
class StartableThread extends StartableBase:
	var _thread : Thread
	var _target : Callable
	var _priority : int
	var _started : bool
	var _joined : AtomicFlag
	
	var thread : Thread:
		get: return self._thread
	
	func _init(target : Callable, priority = Thread.PRIORITY_NORMAL):
		self._thread = Thread.new()
		self._target = target
		self._priority = priority
		self._started = false
		self._joined = AtomicFlag.new()
	
	func _register_thread():
		var id = OS.get_thread_caller_id()
		var l : ReadWriteLock = GDRx.THREAD_MANAGER.THREAD_REGISTRY.at(0)
		l.w_lock()
		GDRx.THREAD_MANAGER.THREAD_REGISTRY.at(1)[id] = self._thread
		l.w_unlock()
	
	func _deregister_thread():
		var id = OS.get_thread_caller_id()
		var l : ReadWriteLock = GDRx.THREAD_MANAGER.THREAD_REGISTRY.at(0)
		l.w_lock()
		GDRx.THREAD_MANAGER.THREAD_REGISTRY.at(1).erase(id)
		l.w_unlock()
	
	func start():
		if self._started:
			GDRx.raise_message("Thread already started!")
			return
		
		var run = func():
			Thread.set_thread_safety_checks_enabled(false)
			self._register_thread()
			self._target.call()
			self._deregister_thread()
		
		self._started = true
		self._thread.start(run, self._priority)
	
	func wait_to_finish():
		if self._joined.test_and_set():
			return
		self._thread.wait_to_finish()
		self._thread = null
		self._target = GDRx.basic.noop

func default_thread_factory(target : Callable) -> StartableThread:
	return StartableThread.new(target)

## Dummy class to represent the main [Thread] instance
class MainThreadDummy_ extends Thread:
	@warning_ignore("native_method_override")
	func start(_callable : Callable, _priority : Priority = PRIORITY_NORMAL) -> Error:
		GDRx.raise_message("Do not launch the Main Thread Dummy!")
		return FAILED
	@warning_ignore("native_method_override")
	func wait_to_finish() -> Variant:
		GDRx.raise_message("Do not join the Main Thread Dummy!")
		return null
	func _to_string():
		return "MAIN_THREAD::" + str(GDRx.MAIN_THREAD_ID)
	@warning_ignore("native_method_override")
	func get_id() -> String:
		return str(GDRx.MAIN_THREAD_ID)
	@warning_ignore("native_method_override")
	func is_started() -> bool:
		return true
	@warning_ignore("native_method_override")
	func is_alive() -> bool:
		return true

## A naive Atomic Flag
class AtomicFlag:
	var _flag : bool
	var _mutex : Mutex
	
	func _init():
		self._flag = false
		self._mutex = Mutex.new()
	
	func test_and_set() -> bool:
		var res : bool
		self._mutex.lock()
		res = self._flag
		self._flag = true
		self._mutex.unlock()
		return res
	
	func clear():
		self._mutex.lock()
		self._flag = false
		self._mutex.unlock()
