extends DisposableBase
class_name InnerSubscription

var subject
var observer
var lock : RLock


func _init(subject_, observer_ = null):
	self.subject = subject_
	self.observer = observer_
	self.lock = RLock.new()
	super._init()

func dispose():
	var __ = LockGuard.new(this.lock)
	if not this.subject.is_disposed and this.observer != null:
		if this.observer in this.subject.observers:
			this.subject.observers.erase(this.observer)
		this.observer = null
