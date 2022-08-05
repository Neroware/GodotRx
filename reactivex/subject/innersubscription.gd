extends DisposableBase
class_name InnerSubscription

var _subject
var _observer
var _lock : RLock


func _init(subject, observer = null):
	self._subject = subject
	self._observer = observer
	self._lock = RLock.new()

func dispose():
	self._lock.lock()
	if not self._subject._is_disposed and self._observer != null:
		if self._observer in self._subject._observers:
			self._subject._observers.erase(self._observer)
			self._observer = null
	self._lock.unlock()
