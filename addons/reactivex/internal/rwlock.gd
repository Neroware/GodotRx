class_name ReadWriteLock

var _w_lock : Lock
var _num_r_lock : Lock
var _num_r : int

func _init():
	self._w_lock = Lock.new()
	self._num_r_lock = Lock.new()
	self._num_r = 0

func r_lock():
	self._num_r_lock.lock()
	self._num_r += 1
	if self._num_r == 1:
		self._w_lock.lock()
	self._num_r_lock.unlock()

func r_unlock():
	if self._num_r <= 0:
		LockNotAquiredError.new(
			"Read-Write-Lock was released but nobody aquired it!").throw()
		return
	self._num_r_lock.lock()
	self._num_r -= 1
	if self._num_r == 0:
		self._w_lock.unlock()
	self._num_r_lock.unlock()

func w_lock():
	self._w_lock.lock()

func w_unlock():
	self._w_lock.unlock()
