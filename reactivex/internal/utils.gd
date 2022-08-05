const MAX_SIZE = 9223372036854775807

class NotSet extends Comparable:
	func eq(other) -> bool:
		return other is self

class InfiniteIterator extends IterableBase:
	var _infval
	var _counter : int
	func _init(infval = GDRx.util.GetNotSet()):
		self._infval = infval
		self._counter = 0
	func next() -> Variant:
		self._counter += 1
		if not self._infval is GDRx.util.NotSet:
			return self._infval
		return self._counter

class WhileIterator extends IterableBase:
	var _it : IterableBase
	var _cond : Callable
	func _init(it : IterableBase, cond : Callable):
		self._it = it
		self._cond = cond
	func next() -> Variant:
		if not self._cond.call():
			return End.new()
		return self._it.next()

func Iter(x : Array, start : int = 0, end : int = -1) -> IterableBase:
	return ArrayIterator.new(x, start, end)

func Infinite(infval = GDRx.util.GetNotSet()) -> IterableBase:
	return InfiniteIterator.new(infval)

func TakeWhile(cond : Callable, it : IterableBase) -> IterableBase:
	return WhileIterator.new(it, cond)

func GetNotSet() -> NotSet:
	return NotSet.new()

func AddRef(xs : Observable, r : RefCountDisposable) -> Observable:
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		return CompositeDisposable.new([
			r.disposable(), 
			xs.subscribe(observer)
		])
	
	return Observable.new(subscribe)
