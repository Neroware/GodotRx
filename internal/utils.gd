const MAX_SIZE = 9223372036854775807

## Represents an un-defined state
class NotSet extends Comparable:
	func eq(other) -> bool:
		return other is NotSet

var NOT_SET : NotSet = NotSet.new()

## Alias for [method to_iterable].
func Iter(x) -> IterableBase:
	return self.to_iterable(x)

## Construct an [IterableBase] onto x.
func to_iterable(x) -> IterableBase:
	return Iterator.to_iterable(x)

### Construct an [Iterator] onto x.
func iter(x) -> Iterator:
	return Iterator.iter(x)

func add_ref(xs : Observable, r : RefCountDisposable) -> Observable:
	var subscribe = func(
		observer : ObserverBase,
		_scheduler : SchedulerBase = null
	) -> DisposableBase:
		return CompositeDisposable.new([
			r.disposable, 
			xs.subscribe(observer)
		])
	
	return Observable.new(subscribe)
