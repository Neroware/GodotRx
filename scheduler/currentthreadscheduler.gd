extends TrampolineScheduler
class_name CurrentThreadScheduler

## Represents an object that schedules units of work on the current thread.
##    You should never schedule timeouts using the [CurrentThreadScheduler],
##    as that will block the thread while waiting.
##
##    Each instance manages a number of trampolines (and queues), one for each
##    thread that calls a [code]schedule(...)[/code] method. These trampolines are automatically
##    garbage-collected when threads disappear, because they're stored in a weak
##    key dictionary.

const cls = "CurrentThreadScheduler"
var _tramps : WeakKeyDictionary

## Obtain a singleton instance for the current thread. Please note, if you
##        pass this instance to another thread, it will effectively behave as
##        if it were created by that other thread (separate trampoline and queue).
## [br]
##        [b]Returns:[/b]
## [br]
##            The singleton [CurrentThreadScheduler] instance.
static func singleton() -> CurrentThreadScheduler:
	var thread = GDRx.get_current_thread()
	var class_map = GDRx.CurrentThreadScheduler_global_.get_value(cls)
	var class_map_ : WeakKeyDictionary
	if class_map == null:
		class_map_ = WeakKeyDictionary.new()
		GDRx.CurrentThreadScheduler_global_.set_pair(cls, class_map_)
	else:
		class_map_ = class_map
	
	var self_
	if not thread in class_map_.keys():
		self_ = CurrentThreadSchedulerSingleton.new()
		class_map_.set_pair(thread, self_)
	else:
		self_ = class_map_.get_value(thread)
	
	return self_

func _init():
	self._tramps = WeakKeyDictionary.new()

## Returns a [Trampoline]
func get_trampoline() -> Trampoline:
	var thread = GDRx.get_current_thread()
	var tramp = self._tramps.get_value(thread)
	if tramp == null:
		tramp = Trampoline.new()
		self._tramps.set_pair(thread, tramp)
	return tramp

class _Local:
	var _tramp : Dictionary
	
	func _trampoline():
		var id = GDRx.get_current_thread()
		if not id in self._tramp.keys():
			self._tramp[id] = Trampoline.new()
		return self._tramp[id]
	
	var tramp : Trampoline: get = _trampoline

class CurrentThreadSchedulerSingleton extends CurrentThreadScheduler:
	func _init():
		pass
	
	func get_trampoline() -> Trampoline:
		return GDRx.CurrentThreadScheduler_local_.tramp
