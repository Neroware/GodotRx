extends RefCounted
class_name ReadWriteLockGuard

## A shared lock guard based on [b]RAII[/b] principle. Uses [ReadWriteLock].

var this : ReadWriteLockGuard

var _lock : ReadWriteLock
var _shared : bool

func _init(lock : ReadWriteLock, shared : bool):
	this = self
	this.unreference()
	
	self._lock = lock
	self._shared = shared
	
	if self._shared:
		self._lock.r_lock()
	else:
		self._lock.w_lock()

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if this._shared: this._lock.r_unlock()
		else: this._lock.w_unlock()

