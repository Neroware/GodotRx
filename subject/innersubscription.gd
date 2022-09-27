extends DisposableBase
class_name InnerSubscription

var subject
var observer
var lock : RLock


func _init(subject, observer = null):
	self.subject = subject
	self.observer = observer
	self.lock = RLock.new()

func dispose():
	self.lock.lock()
	if not self.subject.is_disposed and self.observer != null:
		if self.observer in self.subject.observers:
			self.subject.observers.erase(self.observer)
			self.observer = null
	self.lock.unlock()
