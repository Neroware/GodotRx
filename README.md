# GodotRx - Reactive Extensions for the Godot Game Engine version 4 (GDRx)

A library for composing asynchronous and event-based programs using observable collections and query operator functions in GDScript

## Warning
*While it is almost a direct port of RxPY, this library has not yet been fully battle tested in action. Proceed with caution! Test submissions and bug reports are always welcome!*

## About ReactiveX

ReactiveX for Godot Engine version 4 (GodotRx) is a library for composing asynchronous and event-based programs using observable sequences and pipable query operators in GDScript. Using Rx, developers represent asynchronous data streams with Observables, query asynchronous data streams using operators, and parameterize concurrency in data/event streams using Schedulers. The code was originally ported from RxPY (see: https://github.com/ReactiveX/RxPY) as Python shares a lot of similarities with GDScript.

```swift
source = GDRx.just("Alpha", "Beta", "Gamma", "Delta", "Epsilon")

composed = source \
    .map(func(s): return s.length()) \
    .filter(func(i): return i >= 5)
composed.subscribe(func(value): print("Received: " + value))
```

## Installation
You can add GDRx to your Godot 4 project as followed:

1. Download this repository as an archive.
2. Extract GDRx into your project's `addons` directory. The path needs to be `res://addons/reactivex/`.
3. Add the singleton script at `res://addons/reactivex/__gdrxsingleton__.gd` to autoload as `GDRx`.

GDRx should now be ready to use. Try creating a simple Observable using:

```swift
GDRx.just(42).subscribe(func(i): print("The answer: " + str(i)))
```

## Learning ReactiveX
Unfortunately, GodotRx has no own documentation, however, it is a direct port from RxPY, which is why we refer to its [documentation](https://rxpy.readthedocs.io/en/latest/) for now.

Additional Godot-specific features are located in `res://addons/reactivex/engine/`.

We also refer the the documentation comments in the script files!

## Testing

Add the Testrunner at `res://addons/reactivex/testing/testrunner.gd` to any node in the scene tree.

```swift
extends __GDRx_Test__

const TEST_UNIT_NAME = "BASICS"

func test_rx_map() -> bool:
	var observable = GDRx.of([1, 2, 3, 4])
	var mapped_observable = observable.map(func(x): return x * 2)
	var result = [2, 4, 6, 8, Comp()]
	return await compare(mapped_observable, result)
```

## Additional Godot-specific features

### Coroutines

In GDRx, sequential execution of coroutines can be managed through observable streams, which helps readability.

```swift
var _reference

func coroutine1():
	# ... 
	print("Do something.")
	# ...
	await get_tree().create_timer(1.0).timeout
	# ...
	print("Do something.")
	# ...

func coroutine3():
	await get_tree().create_timer(1.0).timeout
	print("Done.")

func _ready():
	GDRx.concat_streams([
		GDRx.from_coroutine(coroutine1),
		GDRx.if_then(
			func(): return self._reference != null,
			GDRx.from_coroutine(func(): await self._reference.coroutine2())
		),
		GDRx.from_coroutine(coroutine3),
	]).subscribe().dispose_with(self)
```

### Type fixation

Godot does not support generic types of Observables, however, we can still fix the type of a sequence with the oftype operator. Now observers can be sure to always receive items of the wanted type. Generating a wrong type will cause an error notification via the on_error contract. Per default, it also notifies the programmer via a push-error message in the editor.

```swift
var _obs1 : Observable
var _obs2 : Observable

var Obs1 : Observable : #[int]
	get: return self._obs1.oftype(TYPE_INT)
var Obs2 : Observable : #[RefValue]
	get: return self._obs2.oftype(RefValue)

func _ready():
	self._obs1 : Observable = GDRx.from_array([1, 2, 3])
	self._obs2 : Observable = GDRx.just(RefValue.Set(42))
```

### Multi-threading

With GDRx, multithreading is just one scheduling away.

```swift
var nfs : NewThreadScheduler = NewThreadScheduler.singleton()
GDRx.just(0, nfs) \
	.repeat(10) \
	.subscribe(func(__): print("Thread ID: ", OS.get_thread_caller_id())) \
	.dispose_with(self)
```

### Reactive Property

Reactive Properties are a special kind of Observable (and Disposable) which emit items whenever their value is changed. This is very useful e.g. for UI implementations. Creating a ReactiveProperty instance is easy: Access its contents via the Value property inside the ReactiveProperty instance.

```swift
var prop = ReactiveProperty.new(42)
prop.subscribe(func(i): print(">> ", i))

# Emits an item on the stream
prop.Value += 42 

# Sends completion notification to observers and disposes the ReactiveProperty
prop.dispose()
```

### Reactive Collection

A ReactiveCollection works similar to a ReactiveProperty with the main difference that it represents not a single value but a listing of values.

Its constructor supports generators of type IterableBase as well!

```swift
var collection : ReactiveCollection = ReactiveCollection.new(["a", "b", "c", "d", "e", "f"])
```

## Final Thoughts

I do not know if this library is useful in the case of Godot 4 but if you are familiar with and into ReactiveX, go for it!

## Contributing

Contributions and bug reports are always welcome! We also invite folks to submit unit tests verifiying the functionality of GDRx ;)

## License

Distributed under the [MIT License](https://github.com/Neroware/GodotRx/blob/master/LICENSE).