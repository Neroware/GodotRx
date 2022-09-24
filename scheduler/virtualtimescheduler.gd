extends PeriodicScheduler
class_name VirtualTimeScheduler

const MAX_SPINNING = 100

var _clock : float
var _is_enabled : bool
var _lock : Lock
var _queue : PriorityQueue

func _init(initial_clock = 0):
	super._init()
	self._clock = initial_clock
	self._is_enabled = false
	self._lock = Lock.new()
	self._queue = PriorityQueue.new()

func _get_clock() -> float:
	var ret : float
	self._lock.lock()
	ret = self._clock
	self._lock.unlock()
	return ret

var clock : float:
	get:
		return _get_clock()

func now() -> float:
	return self._clock

## Schedule a new action for future execution
func schedule(action : Callable, state = null) -> DisposableBase:
	return self.schedule_absolute(self._clock, action, state)

## Schedule a new action for future execution in [code]duetime[/code] seconds.
func schedule_relative(duetime, action : Callable, state = null) -> DisposableBase:
	var time : float = self.add(self._clock, duetime)
	return self.schedule_absolute(time, action, state)

## Schedule a new action for future execution at [code]duetime[/code].
func schedule_absolute(duetime, action : Callable, state = null) -> DisposableBase:
	var dt : float = duetime
	var si : ScheduledItem = ScheduledItem.new(self, dt, state, action)
	self._lock.lock()
	self._queue.enqueue(si)
	self._lock.unlock()
	return si._disposable

## Starts the virtual time scheduler.
func start():
	self._lock.lock()
	if self._is_enabled:
		self._lock.unlock()
		return
	self._is_enabled = true
	self._lock.unlock()
	
	var spinning : int = 0
	
	while true:
		self._lock.lock()
		
		if not self._is_enabled or self._queue.is_empty():
			self._lock.unlock()
			break
		
		var item : ScheduledItem = self._queue.dequeue()
		
		if item._duetime > self.now():
			self._clock = item._duetime
			spinning = 0
		
		elif spinning > MAX_SPINNING:
			self._clock += 1.0
			spinning = 0
		
		self._lock.unlock()
		
		if not item.is_cancelled():
			item.invoke()
		spinning += 1
	
	self.stop()

## Stops the virtual time scheduler.
func stop():
	self._lock.lock()
	self._is_enabled = false
	self._lock.unlock()

## Advances the schedulers clock to the specified absolute time,
## running all work til that point.
## [br][br]
## [b]Args:[/b] [br]
## [code]time[/code]: Absolute time to advance the schedulers clock to.
func advance_to(time : float):
	var dt : float = time
	self._lock.lock()
	if self.now() > dt:
		GDRx.exc.ArgumentOutOfRangeException.new().throw()
		self._lock.unlock()
		return
	
	if self.now() == dt or self._is_enabled:
		self._lock.unlock()
		return
	
	self._is_enabled = true
	
	self._lock.unlock()
	
	while true:
		self._lock.lock()
		if not self._is_enabled or self._queue.is_empty():
			self._lock.unlock()
			break
		
		var item : ScheduledItem = self._queue.peek()
		
		if item._duetime > dt:
			self._lock.unlock()
			break
		
		if item._duetime > self.now():
			self._clock = item._duetime
		
		self._queue.dequeue()
		
		self._lock.unlock()
		
		if not item.is_cancelled():
			item.invoke()
	
	self._lock.lock()
	self._is_enabled = false
	self._clock = dt
	self._lock.unlock()

## Advances the schedulers clock by the specified relative time,
## running all work scheduled for that timespan.
## [br][br]
## [b]Args:[/b] [br]
## [code]time[/code]: Relative time to advance the schedulers clock by.
func advance_by(time : float):
	self.advance_to(self.add(self.now(), time))

## Advances the schedulers clock by the specified relative time.
## [br][br]
## [b]Args:[/b] [br]
## [code]time[/code]: Relative time to advance the schedulers clock by.
func sleep(time : float):
	var absolute = self.add(self.now(), time)
	var dt : float = absolute
	
	if self.now() > dt:
		GDRx.exc.ArgumentOutOfRangeException.new().throw()
	
	self._lock.lock()
	self._clock = dt
	self._lock.unlock()

## Adds a relative time value to an absolute time value.
## [br][br]
## [b]Args:[/b] [br]
## [code]absolute[/code]: Absolute virtual time value. [br]
## [code]relative[/code]: Relative virtual time value to add. [br]
## [br]
## [b]Returns:[/b] [br]
## The resulting absolute virtual time sum value.
static func add(absolute : float, relative : float) -> float:
	return absolute + relative
