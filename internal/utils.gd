const MAX_SIZE = 9223372036854775807

## Represents an un-defined state
class NotSet extends Comparable:
	func eq(other) -> bool:
		return other is NotSet

## Creates an [ArrayIterable]
func Iter(x : Array, start : int = 0, end : int = -1) -> IterableBase:
	return ArrayIterable.new(x, start, end)

## Creates an [InfiniteIterable]
func Infinite(infval = GDRx.util.GetNotSet()) -> IterableBase:
	return InfiniteIterable.new(infval)

## Creates a [WhileIterable]
func TakeWhile(cond : Callable, it : IterableBase) -> IterableBase:
	return WhileIterable.new(it, cond)

## Creates an instance of [b]NotSet[/b]
func GetNotSet() -> NotSet:
	return NotSet.new()

func AddRef(xs : Observable, r : RefCountDisposable) -> Observable:
	var subscribe = func(
		observer : ObserverBase,
		_scheduler : SchedulerBase = null
	) -> DisposableBase:
		return CompositeDisposable.new([
			r.disposable, 
			xs.subscribe(observer)
		])
	
	return Observable.new(subscribe)
