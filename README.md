# GodotRx - Reactive Extensions for the Godot Game Engine version 4 (GDRx)

## Warning
**Untested** While it is almost a direct port of RxPY, this library has not 
yet been fully tested in action. Proceed with caution!

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
3. Extract GDRx into your project. The folder should be named `res://reactivex/`.
4. Add the singleton script with name 'GDRx' to autoload (`res://reactivex//__gdrxsingleton__.gd`)
5. GDRx should now be ready to use. Try creating a simple Observable using:

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
	]).subscribe()

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
	GDRx.start_periodic_timer(1.0).subscribe(func(i): print("Periodic: ", i))
	GDRx.start_timer(2.0).subscribe(func(i): print("One shot: ", i))
```

If you want to schedule a timer running on a separate thread, the 
ThreadedTimeoutScheduler Singleton allows you to do so. Careful: Once the thread
is started it will not stop until the interval has passed!

```swift
	# Multi-threaded via threaded timer
	GDRx.start_timer(3.0, ThreadedTimeoutScheduler.singleton()) \
		.subscribe(func(i): print("Threaded one shot: ", i))
	GDRx.start_periodic_timer(2.0, ThreadedTimeoutScheduler.singleton()) \
		.subscribe(func(i): print("Threaded periodic: ", i))
```

Additionally, various process and pause modes are possible. I created
a list with various versions of the SceneTreeTimeoutScheduler for this. Access
it like this:

```swift
	# Set timescale
	Engine.time_scale = 0.5

	# Always running with `Engine.time_scale` at process timestep. Due to the
	# given timescale of 0.5, it will take 10 seconds to finish.
	GDRx.start_timer(5.0, GDRx.timeout.Default) \
		.subscribe(func(i): print("Never pauses: ", i))

	# Inherit means running unless paused. Fixed means no timescale.
	# This timer will therefore finish after 5 seconds.
	GDRx.start_timer(5.0, GDRx.timeout.InheritFixed) \
		.subscribe(func(i): print("Pauses: ", i))
```

Note that 'Default' is the one used in the default TimeoutScheduler singleton.
It always runs at process timestep, scaling with `Engine.time_scale`.

### Error handling
In my endless sanity, I throw my own custom exception handling into the ring. 
When an exception is thrown, the Observers should be notified via their 
`on_error()` contract. If this works all the time, I do not know at this point.

```swift
func division(n1 : int, n2 : int) -> int:
	if n2 == 0:
		GDRx.exc.Exception.new("Divided by zero!").throw()
		return -1 # Stops control flow, the -1 has no meaning and is discarded.
	return n1 / n2

func _ready():
	GDRx.from_array([0, 1, 2, 8]) \
		.pairwise() \
		.map(func(i : Tuple): return division(i.at(1), i.at(0))) \
		.subscribe(func(i): print("DIV: ", i), func(e): print("ERR: ", e))
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

** Subscription Management **

It is important to note that if an object is deleted and not all subscriptions
are disposed, this could lead to memory leaks. To account for this, the resulting
subscription (an instance of type `DisposableBase`) can be linked to an object's
lifetime via `DisposableBase.dispose_with(obj : Object)`. Doing so, will cause
the subscription to be disposed, when the receiver in `dispose_with` is deleted.
Only the receiver needs to be linked explicitly. Senders are already considered
automatically by observables representing signals and lifecycle events.

```swift
# Dispose when receiver 'self' is deleted, sender 'anim' already accounted!
GDRx.from_signal(anim.animation_finished).subscribe().dispose_with(self)
# No dispose_with() needed!
GDRx.on_process_as_observable(self).subscribe()
```

*Also a huge shoutout to (https://github.com/semickolon/GodotRx) for his amazing
hack which automatically disposes subscriptions on instance death. Good on ya!*

### Reactive Properties

Reactive Properties are a special kind of Observable which emit items whenever
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
	_Hp.subscribe(func(i): print("Changed Hp ", i))
	_Hp.Value += 10
	print("Reflected: ", self._hp)
```

A ReadOnlyReactiveProperty with read-only access can be created via the
`ReactiveProperty.to_readonly()` method. Trying to set the value will throw
an exception.

```swift
# To ReadOnlyReactiveProperty
var Hp : ReadOnlyReactiveProperty = _Hp.to_readonly()

# Writing to ReadOnlyReactiveProperty causes an exception
GDRx.try(func(): 
	Hp.Value = -100
) \
.catch("Exception", func(exc):
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
TrueDamage.subscribe(func(i): print("True Damage: ", i))
_Stamina.Value = 0.2
_AttackDamage.Value = 90
```

### Reactive Collections

A ReactiveCollection works similar to a ReactiveProperty with the main difference
that it represents not a single value but a listing of values.

```swift
var collection : ReactiveCollection = ReactiveCollection.new(["a", "b", "c", "d", "e", "f"])
```

(I should probably make it support constructor arguments of type `IterableBase` as well...)

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

```swift
extends Node

@export var texture : Texture2D

@onready var _nts : NewThreadScheduler = NewThreadScheduler.new()

var ComputeResult : ReadOnlyReactiveProperty
var _compute_result : ReactiveProperty


func _ready():
	# Let's schedule a new Thread for our Compute Shader
	self._compute_result = ReactiveProperty.new(Vector2i(0, 0))
	self.ComputeResult = self._compute_result.to_readonly()
	self._nts.schedule(func(__, ___): self._compute_shader_thread())
```
Notice that we schedule the CPU-side on a separate Thread using the 
NewThreadScheduler private member. To get the boilerplate out of the way, let's
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
loop and compute shader. First, we create our compute shader as an observable.
Please notice that it is a COLD observable which performs a computation on subscribe,
emits the RenderingDevice as item and then finishes.

```swift
## Runs on separate thread
func _compute_shader_thread():
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

Then, it is only a matter of binding it all together. Let's break this down, shall we?

First, we create an endless loop on our separate Thread using `while_do`. In this
very scenario, since the condition is always 'true', we could also use `repeat_value`,
but we want to be able to terminate the sequence.

Using `flat_map`, for each repeat, we let a new computation commence. 

After the compute shader finishes, we `map` the results from the RenderingDevice 
into a Vector2i data structure. This is useful, because simple equality works. 

Then, we set the value of the ReactiveProperty to our result.

```swift
	# Create the source of our computational value
	GDRx.just(0) \
		.while_do(func(): return true) \
		.flat_map(func(__): return obs_shader) \
		.map(
			func(rd : RenderingDevice):
				var byte_data = rd.buffer_get_data(buffer)
				var output = byte_data.to_int32_array()
				var pb = PackedInt32Array([0,0])
				var pbb = pb.to_byte_array()
				rd.buffer_update(buffer, 0, pbb.size(), pbb)
				return Vector2i(output[0], output[1])
				) \
		.subscribe(func(result : Vector2i): self._compute_result.Value = result)
```

This way, any observer on any thread subscribing to `ComputeResult` is immediatly
notified when the computation results in a new value.

## Final Thoughts

I hope I could clarify the usage of GDRx a bit using some of these examples.

I do not know if this library is useful in the case of Godot 4 but if you are
familiar with and into ReactiveX, go for it!

## License
Distributed under the [MIT License](https://github.com/Neroware/GodotRx/blob/master/LICENSE).
