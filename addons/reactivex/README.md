# GodotRx - Reactive Extensions for the Godot Game Engine version 4 (GDRx)

## Warning
**Untested** While it is almost a direct port of RxPY, this library has not 
yet been fully tested in action. Proceed with caution! (For the native version, 
go to https://github.com/Neroware/NativeGodotRx)

## What is GodotRx?
GodotRx (short: GDRx) is a full implementation of ReactiveX for the Godot Game 
Engine 4. The code was originally ported from RxPY (see: 
https://github.com/ReactiveX/RxPY) as Python shares a lot of similarities with 
GDScript.

**Why Rx?** ReactiveX allows a more declarative programming style working on 
observable data streams. It encourages high cohesion 
and low coupling rendering the code more easily readable and extendable.

The Godot Engine brings a well thought-out event system as well as
a nice implementation of coroutines to the table. It allows you to easily 
implement asynchronous code execution, meaning that code is not run in
the sequence order which it is written in. An observer listens to an 
observable event which fires when something important happens in the program 
resulting in side-effects for the connected instances, this can be e.g. a player
attacking an enemy or an item, which is picked up.

Rx extends this idea by turning all forms of data within the program like 
GD-signals, GD-lifecycle events, callbacks, data structures, coroutines etc. 
into observable data streams which emit items. These data streams, referred to as
'Observables', can be transformed using concepts from the world of functional 
programming. (Say hello to Flat-Map, Reduce and friends!)

## Installation
You can add GDRx to your Godot 4 project as followed:

1. Download this repository as an archive.
2. Navigate to your project root folder.
3. Extract GDRx into your project's `addons` directory. The path needs to be `res://addons/reactivex/`.
4. GDRx should now be ready to use. Try creating a simple Observable using:

```swift
GDRx.just(42).subscribe(func(i): print("The answer: " + str(i)))
```

## Usage

### Type Fixation
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

### Coroutines
Assume we have a coroutine which executes code, awaits a signal and then continues
by calling a second coroutine (in another instance for example) if a condition
is met.

```swift
var _reference

func _ready():
	coroutine1()

func coroutine1():
	# ... 
	print("Do something.")
	# ...
	await get_tree().create_timer(1.0).timeout
	# ...
	print("Do something.")
	# ...
	if self._reference != null:
		await self._reference.coroutine2()
	await coroutine3()

func coroutine3():
	await get_tree().create_timer(1.0).timeout
	print("Done.")
```
Following a good coding style, each of these three coroutines executes one 
specific task, however, the first coroutine is also tasked with handling control
flow (null check of self._reference). GDRx allows us to easily coordinate 
these program parts by providing a declarative execution plan.

```swift
var _reference

func _ready():
	GDRx.concat_streams([
		GDRx.from_coroutine(coroutine1),
		GDRx.if_then(
			func(): return self._reference != null,
			GDRx.from_coroutine(func(): await self._reference.coroutine2())
		),
		GDRx.from_coroutine(coroutine3),
	]).subscribe().dispose_with(self)

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
```
As you can see, coroutine1() now only contains code bound to the task it should
perform. Remember: In good code design, each function should execute a single 
task only!

### Timers
Timers were already possible with coroutines but when running on a separate thread
things get a bit tricky. Godot 4 appears to not support signals on separate 
threads. Also, periodic timers only exist as Node objects. GDRx drastically
simplifies creating timers.

```swift
func _ready():
	# Main Thread via SceneTreeTimer
	GDRx.start_periodic_timer(1.0) \
		.subscribe(func(i): print("Periodic: ", i)) \
		.dispose_with(self)
	GDRx.start_timer(2.0) \
		.subscribe(func(i): print("One shot: ", i)) \
		.dispose_with(self)
```

If you want to schedule a timer running on a separate thread, the 
ThreadedTimeoutScheduler Singleton allows you to do so. Careful: Once the thread
is started it will not stop until the interval has passed!

```swift
	# Multi-threaded via threaded timer
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
	# Set timescale
	Engine.time_scale = 0.5

	var process_always = false
	var process_in_physics = false
	var ignore_time_scale = false

	var scheduler = SceneTreeTimeoutScheduler.singleton(
		process_always, process_in_physics, ignore_time_scale)
```

Note that the default SceneTreeTimeoutScheduler runs at process timestep scaling with 
`Engine.time_scale` and also considers pause mode.

### Await

All observables can be awaited using the corresponding coroutines `next()`, `error()`
and `completed()`. In this case, we have a global periodic timer which emits an item
every three seconds. This way, any part of the program can await the next full tick.

```swift
var timer = GDRx.start_periodic_timer(3.0).publish().auto_connect_observable()
var state = await timer.next()
# Proceed on next full tick...
```

Please note that coroutines with `await` do not work well with the error handling
described in the next section. The tailed execution of an async function
state will not be considered in the observers' `on_error`-contract.
If somebody can implement a better `ErrorHandler` for this case, be my guest!

### Error handling
In my endless sanity, I throw my own custom error handling into the ring. 
When an error is thrown, the Observers should be notified via their 
`on_error()` contract. If this works all the time, I do not know at this point.

```swift
func division(n1 : int, n2 : int) -> int:
	if n2 == 0:
		RxBaserError.new("Divided by zero!").throw()
		return -1 # Stops control flow, the -1 has no meaning and is discarded.
	return n1 / n2

func _ready():
	GDRx.from_array([0, 1, 2, 8]) \
		.pairwise() \
		.map(func(i : Tuple): return division(i.at(1), i.at(0))) \
		.subscribe(func(i): print("DIV: ", i), func(e): print("ERR: ", e)) \
		.dispose_with(self)
```

However, what I do know is that the Integer-division operator crashes if you 
were to divide by zero ;)

This error handling can be especially useful when executing code which can 
generate some form of fail-state like e.g. an HTTPRequest. In this example
we decide what to do if we do not receive the wanted data from our http server.
Using `catch` we can declare alternatives should a specific sequence terminate
with an error.

```swift
func _ready():
	var parser_cb = func(i : String):
		var parser = JSON.new()
		if parser.parse(i):
			return GDRx.raise_message(str(parser.get_error_line()) + ":" + parser.get_error_message())
		return parser.data
	
	var obs : Observable = GDRx.catch([
		GDRx.from_http_request("http://www.mocky.io/v2/5185415ba171ea3a00704eed", "", false, "utf8") \
			.map(func(i): return parser_cb.call(i.decoded)),
		GDRx.from_http_request("https://this.url.should.not.exist.1234567890.de", "", false, "utf8") \
			.map(func(i): return parser_cb.call(i.decoded)),
		GDRx.just({"hello":"world"})
	])
	
	obs.subscribe(func(i): print("hello> ", i["hello"])).dispose_with(self)
```

Do you notice how expressive this approach is? In defining the single higher-order
Observable `obs`, we could implement the concept of a try-catch-like structure just
by listing our alternatives.

### Signals & Node Lifecycle Events

In the world of GDRx, signals and node lifecycle events are all Observables.

```swift
func _ready():
	var OnPhysicsProcess = GDRx.on_physics_process_as_observable(self)
	var OnInput = GDRx.on_input_as_observable(self)
	
	var anim : AnimationPlayer = $AnimationPlayer
	var AnimationFinished : Observable = GDRx.from_signal(anim.animation_finished)
	var AnimOnProcess = GDRx.on_process_as_observable(anim)
```

### Subscription Lifecycle (Disposables)

It is important to note that subscriptions are managed using disposables (an instance of type `DisposableBase`). As soon as a disposable goes out of scope, it will dispose of its managed subscription. (In the 4.0 branch, this was not yet possible due to some issues with Godot's self-reference management in the notification-callback.)

To account for this, the resulting subscription (an instance of type `DisposableBase`) can be linked to an object's lifetime via `DisposableBase.dispose_with(obj : Object)`. Doing so, will cause the subscription to be deleted, whenever the object specified in `dispose_with` is destroyed.

```swift
# Dispose when receiver 'self' is deleted
GDRx.from_signal(anim.animation_finished).subscribe().dispose_with(self)
```

*Also a huge shoutout to (https://github.com/semickolon/GodotRx) for his amazing
hack which automatically disposes subscriptions on instance death. Good on ya!*

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

(Its constructor should support generators of type `IterableBase` as well...)

### Operators

A large set of functional operators can be used to transform observables. **Be careful! I have not tested them all...!**
For more info, also check out the comments in the operator scripts!

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
### Compute Shaders

With GDRx it is quite easy to implement an async interface between GPU and CPU.
This allows some nice implementations of Compute Shaders. For this example, I 
follow the tutorial from (https://www.youtube.com/watch?v=5CKvGYqagyI) and his
shader code. 
In this scenario, we want to sample a texture and count the amount of pixels
with red and blue color. A nice task for GPUs!

The shader code can be found here: https://pastebin.com/pbGGjrE8

First, let's create a script and define a few members. The public member 
`ObserveComputeShader` will be our observable sequence, which emits the
number of red and blue pixels each time these values change.
```swift
extends Node

@export var texture : Texture2D

var _observe_compute_shader : Observable
var ObserveComputeShader : Observable:
	get: return self._observe_compute_shader
```
To get the boilerplate out of the way, let's
create our uniforms from a RenderingDevice and a defined buffer. This helper
function returns our uniform set (we only have a single one with `set = 0`)

```swift
## Helper function to generate the uniform set with id 0 for our shader.
## This represents bindings for 'buffer MyDataBuffer' and 'uniform sampler2D tex'
func _get_uniform_set(rd : RenderingDevice, buffer) -> Array[RDUniform]:
	var buffer_uniform = RDUniform.new()
	buffer_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	buffer_uniform.binding = 0
	buffer_uniform.add_id(buffer)
	
	var img = texture.get_image()
	var img_pba = img.get_data()
	
	var fmt = RDTextureFormat.new()
	fmt.width = 2048
	fmt.height = 2048
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT
	fmt.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_SRGB
	
	var v_tex = rd.texture_create(fmt, RDTextureView.new(), [img_pba])
	var samp_state = RDSamplerState.new()
	samp_state.unnormalized_uvw = true
	var samp = rd.sampler_create(samp_state)
	
	var tex_uniform = RDUniform.new()
	tex_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
	tex_uniform.binding = 1
	tex_uniform.add_id(samp)
	tex_uniform.add_id(v_tex)
	
	return [buffer_uniform, tex_uniform]
```
With that out of the way, we now get to the spicy part. Setting up our computation
loop and logic. First, we create an observable from a compute shader using the 
`GDRx.from_compute_shader(...)` constructor. This generates an observable which
commences and schedules the shader on the GPU, emits the rendering device when
the shader finishes and then terminates the sequence causing all observers to
disconnect.

```swift
func _ready():
	var rd = RenderingServer.create_local_rendering_device()
	var pba = PackedInt32Array([0,0]).to_byte_array()
	var buffer = rd.storage_buffer_create(pba.size(), pba)
	
	# Get Uniform Set with id 0
	var uniform_set0 = self._get_uniform_set(rd, buffer)
	
	# Create the Observable from the compute shader
	var obs_shader = GDRx.from_compute_shader(
		"res://compute_shaders/test_compute_shader.glsl",
		rd, Vector3i(2048/8, 2048/8, 1),
		[uniform_set0]
	)
```

When this is done, we can define the private member `_observe_compute_shader` 
which is going to behave as described at the beginning of this section.

```swift
self._observe_compute_shader = GDRx.merge([
		GDRx.just(Vector2i(-1, -1)),
		GDRx.just(0) \
		.while_do(func(): return true) \
		.flat_map(obs_shader) \
		.map(
			func(rd : RenderingDevice):
				var byte_data = rd.buffer_get_data(buffer)
				var output = byte_data.to_int32_array()
				var pb = PackedInt32Array([0,0])
				var pbb = pb.to_byte_array()
				rd.buffer_update(buffer, 0, pbb.size(), pbb)
				return Vector2i(output[0], output[1])
				)
		.publish() \
		.auto_connect_observable() \
		.subscribe_on(NewThreadScheduler.new())
		]) \
	.pairwise()  \
	.filter(func(tup : Tuple): return tup.at(0) != tup.at(1)) \
	.map(func(tup : Tuple): return tup.at(1))
	
	self.ObserveComputeShader.subscribe(func(result : Vector2i): print("> ", result)) \
		.dispose_with(self)
```

Okay, now I lost you, am I right? Let's break it down, shall we? 

- The `GDRx.just(...)` constructor just emits the value specified, then terminates.
- In this scenario, we also use the `GDRx.merge([...])` constructor. This causes
the resulting observable to emit all items of its children (in this case 
`GDRx.just(Vector2i(-1, -1))` and the second larger part).
- Using `GDRx.just(0).while_do(func(): return true)` we describe a sequence which emits
zero as long as the condition `func(): return true` is met. This simulates a while-loop.
- The `flat_map` operator emits all items of the observable given to it each time its parent
emits an item. This causes a new computation on the GPU each tick.
- The `map` operator maps an incoming item to a new value. In this case, we read the
result the GPU computed using the rendering device emitted by `obs_shader` and map
it to a `Vector2i`.
- Since we do not want to have computations running per observer we publish the sequence
using `publish` and `auto_connect_observable`. As stated earlier, `obs_shader` is a COLD
observable which would otherwise commence a computaton per subscriber.
- The `subscribe_on` allows us to subscribe to the sequence on a new thread using
the `NewThreadScheduler`. This means waiting for the GPU will not block the main thread.
- The `pairwise` takes the n-th and (n-1)-th item and merges them in a tuple.
- With `filter` we check if the current value is different from the previous.
- Then `map` just takes the second, n-th item from the pair.
- Finally, we can subscribe to `ObserveComputeShader` to receive the pixel counts each time 
they are changed.

## Final Thoughts

I hope I could clarify the usage of GDRx a bit using some of these examples.

I do not know if this library is useful in the case of Godot 4 but if you are
familiar with and into ReactiveX, go for it!

## License
Distributed under the [MIT License](https://github.com/Neroware/GodotRx/blob/master/LICENSE).
