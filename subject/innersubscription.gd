extends DisposableBase
class_name InnerSubscription

var subject
var observer
var lock : RLock


func _init(subject_, observer_ = null):
	self.subject = subject_
	self.observer = observer_
	self.lock = RLock.new()

func dispose():
	var __ = LockGuard.new(self.lock)
	if not self.subject.is_disposed and self.observer != null:
		if self.observer in self.subject.observers:
			self.subject.observers.erase(self.observer)
		self.observer = null
