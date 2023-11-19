## Represents a Compute Shader as an Observable Sequence.
## [br][br]
## Please note: This is a [b]cold[/b] [Observable]. It transfers data to GPU
## on subscribe. Thus, each subscription causes one computational step.
## When the compute shader finishes, the [RenderingDevice] is emitted as item.
## Afterwards the stream completes.
## [br][br]
## [b]Args:[/b]
##    [br]
##    [code]shader_path[/code] the path to the GLSL file with the shader source
##    [br]
##    [code]rd[/code] The current instance of [RenderingDevice]
##    [br]
##    [code]work_groups[/code]: Set x, y and z dimensions of work groups.
##    [br]
##    [code]uniform_sets[/code]: A list containing lists of [RDUniform]
##    representing n uniform sets starting with [code]set = 0[/code] going 
##    upwards.
##    [br]
##    [code]scheduler[/code]: Schedules the CPU side of the shader computation
##    [br][br]
##    [b]Return:[/b]
##    An observable sequence which performs a new computation on the device,
##    each time an [Observer] subscribes.
static func from_compute_shader_(
	shader_path : String,
	rd : RenderingDevice,
	work_groups : Vector3i,
	uniform_sets : Array = [],
	scheduler : SchedulerBase = null
) -> Observable:
	
	# Create shader and pipeline
	var shader_file = load(shader_path)
	var shader_spirv = shader_file.get_spirv()
	var shader = rd.shader_create_from_spirv(shader_spirv)
	var pipeline = rd.compute_pipeline_create(shader)
	
	var uniform_sets_rids = []
	for sid in range(uniform_sets.size()):
		uniform_sets_rids.append(
			rd.uniform_set_create(uniform_sets[sid], shader, sid)
		)
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler_ : SchedulerBase = null
	) -> DisposableBase:
		
		var _scheduler
		if scheduler != null: _scheduler = scheduler
		elif scheduler_ != null: _scheduler = scheduler_
		else: _scheduler = CurrentThreadScheduler.singleton()
		
		var action = func(_scheduler = null, _state = null):
			# Setup compute pipeline and uniforms
			var compute_list = rd.compute_list_begin()
			rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
			for sid in range(uniform_sets_rids.size()):
				rd.compute_list_bind_uniform_set(compute_list, uniform_sets_rids[sid], sid)
			rd.compute_list_dispatch(compute_list, work_groups.x, work_groups.y, work_groups.z)
			rd.compute_list_end()
			
			# Send to GPU
			rd.submit()
			# Sync with CPU
			rd.sync()
			
			observer.on_next(rd)
			observer.on_completed()
		
		return _scheduler.schedule(action)
	
	return Observable.new(subscribe)
