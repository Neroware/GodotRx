extends RefCounted
class_name LockGuard

## A basic lock guard based on [b]RAII[/b] principle.
## 
## I had been unable to pull this off. Because it frustrates me to replace all
## [method LockBase.lock] and [method LockBase.unlock] calls with this, I will
## explain why: When I started to develop [b]GodotRx[/b] I ran into a problem:
## The NOTIFICATION_PREDELETE is received, when the [b]self[/b] reference 
## already results in a [b]null[/b]-value. I will now use the approach from
## [b]std::enable_shared_from_this[/b] using an uncounted reference as member.
## This appears to work as intended.
## 
## Also, I learned a lot of C++ practices when creating NativeGodotRx ;)

var this : LockGuard

var _lock : LockBase

func _init(lock : LockBase):
	this = self
	this.unreference()
	
	self._lock = lock
	self._lock.lock()

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		this._lock.unlock()
