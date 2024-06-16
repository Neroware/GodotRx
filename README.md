# GodotRx - Reactive Extensions for the Godot Game Engine version 4 (GDRx)

(For the native version, 
go to https://github.com/Neroware/NativeGodotRx)

## Warning
**Untested** While it is almost a direct port of RxPY, this library has not 
yet been fully battle tested in action. Proceed with caution! Test submissions
and bug reports are welcome!

## What is GodotRx?
GodotRx (short: GDRx) is a full implementation of ReactiveX for the Godot Game 
Engine 4. The code was originally ported from RxPY (see: 
https://github.com/ReactiveX/RxPY) as Python shares a lot of similarities with 
GDScript.

**Why Rx?** ReactiveX allows a more declarative programming style working on 
observable data streams. It encourages high cohesion 
and low coupling rendering the code more easily readable and extendable.

The Godot Engine offers a robust event system in form of signals and a seamless implementation of coroutines, making it easy to execute asynchronous code. This allows you to run code outside of the typical sequential order, which is essential for handling complex tasks like user inputs, network responses, and animations.

In this context, an observer listens to an observable event, which triggers when something significant occurs in the program, leading to side effects in the connected instances. For example, this could be a player attacking an enemy on button press or picking up an item when a collision is detected.

GDRx enhances this idea by converting all forms of data within the program, such as GD-signals, GD-lifecycle events, callbacks, data structures, coroutines, etc., into observable data streams that emit items. These data streams, known as 'Observables', are immutable and can be transformed using functional programming techniques to describe more complex behavior. (Say hello to Flat-Map, Filter, Reduce, and their functional friends!)

## Installation
You can add GDRx to your Godot 4 project as followed:

1. Download this repository as an archive.
2. Navigate to your project root folder.
3. Extract GDRx into your project's `addons` directory. The path needs to be `res://addons/reactivex/`.
4. Ensure that the plugin is enabled.
5. Check if the singleton script at `res://addons/reactivex/__gdrxsingleton__.gd` is included as `GDRx`.
6. GDRx should now be ready to use. Try creating a simple Observable using:

```swift
GDRx.just(42).subscribe(func(i): print("The answer: " + str(i)))
```

## Features

GDRx is a full implementation of the Observer design pattern combined with the Iterator design pattern.
The following classes are featured:

**Observer:** An observer is an entity that listens to an observable sequence. In standard GDScript, you would connect a `Callable` to a `Signal` creating an implicit observer that receives a notification from the signal and forwards it to the corresponding callback. In GDRx, each observer follows a strict contract consisting of the three notifications `on_next(item)`, `on_error(error)` and `on_completed()`.

**Observable:** An observable is an entity that can be subscribed to by an observer. This is achieved through the subscription-operator, a method with the signature `subscribe(on_next, on_error, on_completed)`. Whenever an observer subscribes to the observables via the subscription-method it receives notifications from the observer-observable-contract over the course of the observer's active subscription.


**Disposable:** Disposables are entities that represent subscriptions in GDRx. They are used for clean-up and dispose themselves automatically when they go out of scope or when the method `dispose()` is called explicitly. The subscription-operator returns the new subscription (in Godot you would call it connection) as a disposable. Since disposables delete themselves when going out of scope, their lifetime can be linked to another object's lifetime via the method `dispose_with(obj)`.
*Also a huge shoutout to Semickolon (https://github.com/semickolon/GodotRx) for his amazing
hack which automatically disposes subscriptions on instance death. Good on ya!*

**Scheduler:** Schedulers schedule pieces of work (actions) for execution. The most prominent scheduling strategies in GDRx are as followed:

- *ImmediateScheduler:* Schedules actions to be executed immediately. This would be equivalent to invoking the action directly.
- *TrampolineScheduler:* A scheduler with additional protection against recursive scheduling.
- *CurrentThreadScheduler:* A TrampolineScheduler that schedules actions on the current thread. This is usually the default scheduling strategy.
- *EventLoopScheduler:* Creates a new thread and schedules all actions on it.
- *NewThreadScheduler:* Creates a new thread for each scheduled action.
- *SceneTreeTimeoutScheduler:* Schedules actions for execution after a timeout has expired. The timer is based on Godot's `SceneTreeTimer`.
- *ThreadedTimeoutscheduler:* Schedules actions for execution after a timeout has expired. The timer is run on a separate thread.
- *PeriodicScheduler:* Allows periodic scheduling of actions.
- *GodotSignalScheduler:* Schedules an action for execution after a `Signal` is received.

**Iterable:** Iterables are sequences that can be iterated using Godot's `for`-loop. They become relevant when working with observable data streams and can also be infinite.

**Subject:** A subject implements both observable and observer behavior meaning it can receive notifications and allow other observers to subscribe to it at the same time.

**ReactiveProperty:** A reactive property is a special form of observable that maintains a value and sends notifications whenever a change to said value occurs. Highly useful!

**Operator:** An operator is a function taking an observable sequence and transforming it to another. A large set of functional operators can be used to transform observables. **Be careful! I have not tested them all...! Test submissions are welcome!** For more info, also check out the comments in the operator scripts!

**Throwable:** The item of an `on_error`-notification. Raising an error sends a notification to all observers of the corresponding observable sequence, which terminates the stream ungracefully. This does not work with observables containing coroutines due to Godot's technical limitations!

*For more information, it is recommended to read the RxPY documentation, which covers all the features of GDRx that are not directly related to the Godot Engine.*

## Usage

### Basics

In GodotRx, an observer listens to an observable sequence. The `GDRx`-singleton contains a selection of constructors:

```swift
var observable = GDRx.from([1, 2, 3, 4])
```

A connection can be established via `Observable.subscribe(...)` as followed:

```swift
var subscription = observable.subscribe(
    func(i): print("next> ", i), 
    func(e): print("Err> ", e), 
    func(): print("Completed!"))
```

A subscription is automatically disposed whenever it goes out of scope. Do not forget to link subscription lifetime to an object via `Disposable.dispose_with(obj)`:

```swift
GDRx.start_periodic_timer(1.0) \
    .subscribe(func(i): print("Tick: ", i)) \
    .dispose_with(self)
```

### Timers

Timers were already possible either by using the `Timer`-Node or by combining a coroutine with an awaited timeout signal of a `SceneTreeTimer`. For periodic timers, code gets even more convoluted. GDRx drastically simplifies creating timers.

```swift
func _ready():
	GDRx.start_periodic_timer(1.0) \
		.subscribe(func(i): print("Periodic: ", i)) \
		.dispose_with(self)
	GDRx.start_timer(2.0) \
		.subscribe(func(i): print("One shot: ", i)) \
		.dispose_with(self)
```

If you want to schedule a timer running on a separate thread, the 
ThreadedTimeoutScheduler Singleton allows you to do so. **Careful:** Once the thread
is started it will not stop until the interval has passed!

```swift
	GDRx.start_timer(3.0, ThreadedTimeoutScheduler.singleton()) \
		.subscribe(func(i): print("Threaded one shot: ", i)) \
		.dispose_with(self)
	GDRx.start_periodic_timer(2.0, ThreadedTimeoutScheduler.singleton()) \
		.subscribe(func(i): print("Threaded periodic: ", i)) \
		.dispose_with(self)
```

Additionally, various process and pause modes are possible. I created
a list with various versions of the SceneTreeTimeoutScheduler for this. Access
them like this:

```swift
	Engine.time_scale = 0.5

	var process_always = false
	var process_in_physics = false
	var ignore_time_scale = false

	var scheduler = SceneTreeTimeoutScheduler.singleton(
		process_always, process_in_physics, ignore_time_scale)
```

Note that the default SceneTreeTimeoutScheduler runs at process timestep scaling with 
`Engine.time_scale` and also considers pause mode.


### Transforming signals

A very nice feature of GodotRx are signal transformations through observables. Let us take a simple example with two signals. Assume, we only want to execute logic, when both signals are emitted. In Godot, this would require some additional logic in the signal's callbacks. In GDRx, this can be achieved this behavior through observable transformations.

```swift
signal signal_a(a)
signal signal_b(b)

var combined_signal : Observable

func _ready():
    combined_signal = GDRx.from_signal(signal_a) \
        .zip([GDRx.from_signal(signal_b)])
```

Using the `from_signal`-constructor, an observable can be created on top of a signal, which emits items whenever the signal is emitted. Using the `zip`-operator, the resulting observable only emits items, when both signals have been emitted. This even has the advantages that the resulting observable can be passed around like a `Signal` instance as first-class-citizen.

### Error handling

GDRx features custom error handling. Raising an error inside an observable sequence causes all observers to be notified with said error. The following is an example of a safe division operation.

```swift
var safe_division = func(a, b):
	return a / b if b != 0 else DividedByZeroError.raise(-1)
var mapped = GDRx.of([6, 2, 1, 0, 2, 1]) \
	.pairwise() \
	.map(func(tup : Tuple): return safe_division.call(tup.first, tup.second))
```

This code results in the sequence "3, 2" after which the observers are notified with a "DividedByZeroError" notification terminating the observable.

**Warning** It is currently technically impossible to get the error handling working with asynchronous GDScript, meaning this will break in scenarios were errors are raised after an `await`-statement. If somebody has a solution to this problem, feel free to send me an E-Mail or answer to issue #20!

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

GDScript is a fully dynamically typed language. This has many advantages, however, 
at some point, we might want to fix types of a certain computation. 
After all, variables can get type hints as well! Since Godot does not support
generic types of Observables, we can still fix the type of a sequence with the
`oftype` operator. Now observers can be sure to always receive items of the wanted type.
Generating a wrong type will cause an error notification via the `on_error` contract. Per
default, it also notifies the programmer via a push-error message in the editor.

This would be a good style, I think:
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

### Multithreading

With GDRx multithreading is just one scheduling away.

```swift
var nfs : NewThreadScheduler = NewThreadScheduler.singleton()
GDRx.just(0, nfs) \
	.repeat(10) \
	.subscribe(func(__): print("Thread ID: ", OS.get_thread_caller_id())) \
	.dispose_with(self)
```

Threads terminate automatically when they finish computation. No need to call `Thread.wait_to_finish()`.

## Godot Features

### Reactive Properties

Reactive Properties are a special kind of Observable (and Disposable) which emit items whenever
their value is changed. This is very useful e.g. for UI implementations.
Creating a ReactiveProperty instance is straight forward. Access its contents
via the `Value` property inside the ReactiveProperty instance.

```swift
var prop = ReactiveProperty.new(42)
prop.subscribe(func(i): print(">> ", i))

# Emits an item on the stream
prop.Value += 42 

# Sends completion notification to observers and disposes the ReactiveProperty
prop.dispose()

```

Sometimes we want to construct a ReactiveProperty from a class member. This can
be done via the `ReactiveProperty.FromMember()` constructor. The changed value 
is reflected onto the class member, though changing the member will NOT change
the value of the ReactiveProperty.

```swift
var _hp : int = 100

var _stamina : float = 1.0
var _attack_damage : int = 100

func _ready():
	# Create ReactiveProperty from member
	var _Hp : ReactiveProperty = ReactiveProperty.FromMember(self, "_hp")
	var __ = _Hp.subscribe(func(i): print("Changed Hp ", i))
	_Hp.Value += 10
	print("Reflected: ", self._hp)
```

A ReadOnlyReactiveProperty with read-only access can be created via the
`ReactiveProperty.to_readonly()` method. Trying to set the value will throw
an error.

```swift
# To ReadOnlyReactiveProperty
var Hp : ReadOnlyReactiveProperty = _Hp.to_readonly()

# Writing to ReadOnlyReactiveProperty causes an error
GDRx.try(func(): 
	Hp.Value = -100
) \
.catch("Error", func(exc):
	print("Err: ", exc)
) \
.end_try_catch()
```

A ReactiveProperty can also be created from a Setter and a Getter function

```swift
# Create Reactive Property from getter and setter
var set_stamina = func(v):
	print("Setter Callback")
	self._stamina = v

var get_stamina = func() -> float:
	print("Getter Callback")
	return self._stamina

var _Stamina = ReactiveProperty.FromGetSet(get_stamina, set_stamina)
_Stamina.Value = 0.8
print("Reflected> ", self._stamina)
```

A ReadOnlyReactiveProperty can also represent a computational step from a set
of other properties. When one of the underlying properties is changed, the 
computed ReadOnlyReactiveProperty emits an item accordingly. A computed
ReadOnlyReactiveProperty can be created via the `ReactiveProperty.Computed{n}()`
constructor.

```swift
var Stamina : ReadOnlyReactiveProperty = _Stamina.to_readonly()
var _AttackDamage : ReactiveProperty = ReactiveProperty.FromMember(
	self, "_attack_damage")
var AttackDamage : ReadOnlyReactiveProperty = _AttackDamage.to_readonly()

# Create a computed ReadOnlyReactiveProperty
var TrueDamage : ReadOnlyReactiveProperty = ReactiveProperty.Computed2(
	Stamina, AttackDamage,
	func(st : float, ad : int): return (st * ad) as int
)
TrueDamage.subscribe(func(i): print("True Damage: ", i)).dispose_with(self)
_Stamina.Value = 0.2
_AttackDamage.Value = 90
```

### Reactive Collections

A ReactiveCollection works similar to a ReactiveProperty with the main difference
that it represents not a single value but a listing of values.

```swift
var collection : ReactiveCollection = ReactiveCollection.new(["a", "b", "c", "d", "e", "f"])
```

Its constructor supports generators of type `IterableBase` as well...

### Input Events

Very frequent input events are included as observables:

```swift
GDRx.on_mouse_down() \
	.filter(func(ev : InputEventMouseButton): return ev.button_index == 1) \
	.subscribe(func(__): print("Left Mouse Down!")) \
	.dispose_with(self)

GDRx.on_mouse_double_click() \
	.filter(func(ev : InputEventMouseButton): return ev.button_index == 1) \
	.subscribe(func(__): print("Left Mouse Double-Click!")) \
	.dispose_with(self)

GDRx.on_key_pressed(KEY_W) \
	.subscribe(func(__): print("W")) \
	.dispose_with(self)
```

### Frame Events

Main frame events can be directly accessed as observables as well:

```swift
# Do stuff before `_process(delta)` calls.
GDRx.on_idle_frame() \
	.subscribe(func(delta : float): print("delta> ", delta)) \
	.dispose_with(self)

# Do stuff before `_physics_process(delta)` calls.
GDRx.on_physics_step() \
	.subscribe(func(delta : float): print("delta> ", delta)) \
	.dispose_with(self)

# Emits items at pre-draw
GDRx.on_frame_pre_draw() \
	.subscribe(func(__): print("Pre Draw!")) \
	.dispose_with(self)

# Emits items at post-draw
GDRx.on_frame_post_draw() \
	.subscribe(func(__): print("Post Draw!")) \
	.dispose_with(self)
```

## Final Thoughts

I hope I could clarify the usage of GDRx a bit using some of these examples.

I do not know if this library is useful in the case of Godot 4 but if you are
familiar with and into ReactiveX, go for it!

## Contributing

Contributions and bug reports are always welcome! We also invite folks to submit unit tests verifiying the functionality of GDRx ;)

## License

Distributed under the [MIT License](https://github.com/Neroware/GodotRx/blob/master/LICENSE).
