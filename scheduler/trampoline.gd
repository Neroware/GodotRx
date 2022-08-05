class_name Trampoline

var _idle : bool
var _queue : PriorityQueue
var _lock : Lock
var _condition : ConditionalVariable

func _init():
	self._idle = true
	self._queue = PriorityQueue.new()
	self._lock = Lock.new()
	self._condition = ConditionalVariable.new(self._lock)

func idle() -> bool:
	var ret : bool
	self._lock.lock()
	ret = self._idle
	self._lock.unlock()
	return ret

func run(item : ScheduledItem):
	self._lock.lock()
	self._queue.enqueue(item)
	if self._idle:
		self._idle = false
		self._lock.unlock()
	else:
		self._condition.notify()
		self._lock.unlock()
		return
	
	self._run()
	
	self._lock.lock()
	self._idle = true
	self._queue.clear()
	self._lock.unlock()

func _run():
	var ready : Array[ScheduledItem]
	while true:
		self._lock.lock()
		while(self._queue.size() > 0):
			var item : ScheduledItem = self._queue.peek()
			if item._duetime <= item._scheduler.now():
				self._queue.dequeue()
				ready.append(item)
			else:
				break
		self._lock.unlock()
		
		while ready.size() > 0:
			var item : ScheduledItem = ready.pop_front()
			if not item.is_cancelled():
				item.invoke()
		
		self._lock.lock()
		if self._queue.size() == 0:
			self._lock.unlock()
			break
		var item : ScheduledItem = self._queue.peek()
		var seconds = Scheduler.to_seconds(item._duetime - item._scheduler.now())
		if seconds > 0.0:
			self._condition.wait(seconds)
		self._lock.unlock()
