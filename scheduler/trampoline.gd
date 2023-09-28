class_name Trampoline

var _idle : bool
var _queue : PriorityQueue
var _lock : Lock
var _condition : ConditionalVariable

func _init():
	self._idle = true
	self._queue = PriorityQueue.new()
	self._lock = Lock.new()
	self._condition = ConditionalVariable.new()

func idle() -> bool:
	var __ = LockGuard.new(self._lock)
	return self._idle

func run(item : ScheduledItem):
	if true:
		var __ = LockGuard.new(self._lock)
		self._queue.enqueue(item)
		if self._idle:
			self._idle = false
		else:
			self._condition.notify()
			return
	
	GDRx.try(self._run).end_try_catch()
	
	if true:
		var __ = LockGuard.new(self._lock)
		self._idle = true
		self._queue.clear()

func _run():
	var ready : Array[ScheduledItem] = []
	while true:
		if true:
			var __ = LockGuard.new(self._lock)
			while(self._queue.size() > 0):
				var item : ScheduledItem = self._queue.peek()
				if item.duetime <= item.scheduler.now():
					self._queue.dequeue()
					ready.append(item)
				else:
					break
		
		while ready.size() > 0:
			var item : ScheduledItem = ready.pop_front()
			if not item.is_cancelled():
				item.invoke()
		
		if true:
			var __ = LockGuard.new(self._lock)
			if self._queue.size() == 0:
				break
			var item : ScheduledItem = self._queue.peek()
			var seconds = item.duetime - item.scheduler.now()
			if seconds > 0.0:
				self._condition.wait_for(self._lock, seconds)
