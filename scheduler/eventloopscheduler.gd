extends PeriodicScheduler
class_name EventLoopScheduler

## Creates an object that schedules units of work on a designated thread.

var _is_disposed : bool
var _thread_factory : Callable
var _thread : StartableBase
var _condition : ConditionalVariable
var _queue : PriorityQueue
var _ready_list : Array[ScheduledItem]

var _exit_if_empty : bool

func _init(
	thread_factory : Callable = GDRx.concur.default_thread_factory,
	exit_if_empty : bool = false
):
	super._init()
	self._is_disposed = false
	self._thread_factory = thread_factory
	self._thread = null
	self._condition = ConditionalVariable.new(Lock.new())
	self._queue = PriorityQueue.new()
	self._ready_list = []
	
	self._exit_if_empty = exit_if_empty

## Schedule a new action for future execution
func schedule(action : Callable, state = null) -> DisposableBase:
	return self.schedule_absolute(self.now(), action, state)

## Schedule a new action for future execution in [code]duetime[/code] seconds.
func schedule_relative(duetime, action : Callable, state = null) -> DisposableBase:
	duetime = max(DELTA_ZERO, duetime)
	return self.schedule_absolute(self.now() + duetime, action, state)

## Schedule a new action for future execution at [code]duetime[/code].
func schedule_absolute(duetime, action : Callable, state = null) -> DisposableBase:
	if self._is_disposed:
		GDRx.exc.DisposedException.new().throw()
		return Disposable.new()
	
	var dt = duetime
	var si : ScheduledItem = ScheduledItem.new(self, dt, state, action)
	
	self._condition.lock()
	if dt <= self.now():
		self._ready_list.append(si)
	else:
		self._queue.enqueue(si)
	self._condition.notify() # signal that a new item is available
	self._ensure_thread()
	self._condition.unlock()
	
	return Disposable.new(si.cancel)

## Schedule a periodic action for repeated execution every time
## [code]period[/code] seconds have expired.
func schedule_periodic(
	period : float,
	action : Callable,
	state = null) -> DisposableBase:
		if self._is_disposed:
			GDRx.exc.DisposedException.new().throw()
			return Disposable.new()
		
		return super.schedule_periodic(period, action, state)

## Checks if there is an event loop thread running.
func _has_thread() -> bool:
	var ret : bool
	self._condition.lock()
	ret = not self._is_disposed and self._thread != null
	self._condition.unlock()
	return ret

## Ensures there is an event loop thread running. Should be called under the gate.
func _ensure_thread():
	if self._thread == null:
		var thread : StartableBase = self._thread_factory.call(self.run)
		self._thread = thread
		thread.start()

## Event loop scheduled on the designated event loop thread. 
## The loop is suspended/resumed using the condition which gets notified
## by calls to Schedule or calls to dispose.
func run():
	var ready : Array[ScheduledItem] = []
	
	while true:
		
		self._condition.lock()
		# The notification could be because of a call to dispose. This
		# takes precedence over everything else: We'll exit the loop
		# immediately. Subsequent calls to Schedule won't ever create a
		# new thread.
		
		if self._is_disposed:
			self._condition.unlock()
			return
		
		# Sort the ready_list (from recent calls for immediate schedule)
		# and the due subset of previously queued items.
		var time = self.now()
		while not self._queue.is_empty():
			var due = self._queue.peek()._duetime
			while self._ready_list and due > self._ready_list[0]._duetime:
				ready.append(self._ready_list.pop_front())
			if due > time:
				break
			ready.append(self._queue.dequeue())
		while not self._ready_list.is_empty():
			ready.append(self._ready_list.pop_front())
		
		self._condition.unlock()
		
		# Execute the gathered actions
		while not ready.is_empty():
			var item = ready.pop_front()
			if not item.is_cancelled():
				item.invoke()
		
		# Wait for next cycle, or if we're done let's exit if so configured
		self._condition.lock()
		
		if not self._ready_list.is_empty():
			self._condition.unlock()
			continue
		
		elif self._queue:
			time = self.now()
			var item = self._queue.peek()
			var seconds = item._duetime - time
			if seconds > 0:
				#print("timeout: ", seconds)
				self._condition.wait(seconds)
		
		elif self._exit_if_empty:
			self._thread = null
			self._condition.unlock()
			return
		
		else:
			self._condition.wait()
		
		self._condition.unlock()

## Ends the thread associated with this scheduler. All
## remaining work in the scheduler queue is abandoned.
func dispose():
	self._condition.lock()
	if not self._is_disposed:
		self._is_disposed = true
		self._condition.notify()
	self._condition.lock()

## Transforms this scheduler into a [Disposable]
func as_disposable() -> Disposable:
	return Disposable.new(dispose)
