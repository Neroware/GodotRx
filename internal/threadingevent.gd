class_name ThreadingEvent

## Class implementing event objects.
## 
## Events manage a flag that can be set to [b]true[/b] with the [method set_flag] method and reset
## to [b]false[/b] with the [method clear] method. The [method wait] method blocks until the flag is
## [b]true[/b]. The flag is initially [b]false[/b].

var _cond : ConditionalVariable
var _lock : Lock
var _flag : bool

func _init():
	self._cond = ConditionalVariable.new()
	self._lock = Lock.new()
	self._flag = false

## Return [b]true[/b] if and only if the internal flag is [b]true[/b].
func is_set() -> bool:
	return self._flag

## Set the internal flag to [b]true[/b].
##
## All threads waiting for it to become [b]true[/b] are awakened. Threads
## that call [method wait] once the flag is [b]true[/b] will not block at all.
func set_flag():
	self._lock.lock()
	self._flag = true
	self._cond.notify_all()
	self._lock.unlock()

## Reset the internal flag to [b]false[/b].
##
## Subsequently, threads calling [method wait] will block until [method set_flag] is called to
## set the internal flag to [b]true[/b] again.
func clear():
	self._lock.lock()
	self._flag = false
	self._lock.unlock()

## Block until the internal flag is [b]true[/b].
##
## If the internal flag is [b]true[/b] on entry, return immediately. Otherwise,
## block until another thread calls [method set_flag] to set the flag to [b]true[/b], or until
## the optional timeout occurs.
##
## When the [code]timeout[/code] argument is present and not [b]null[/b], it should be a
## floating point number specifying a timeout for the operation in seconds
## (or fractions thereof).
##
## This method returns the internal flag on exit, so it will always return
## [b]true[/b] except if a timeout is given and the operation times out.
##
func wait(timeout = null):
	var __ = LockGuard.new(self._lock)
	if not self._flag and timeout:
		self._cond.wait_for(self._lock, timeout)
	elif not self._flag:
		self.wait(self._lock)
	return self._flag
