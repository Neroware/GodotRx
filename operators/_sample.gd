static func sample_observable(
	source : Observable, sampler : Observable
) -> Observable:
	
	var subscribe = func(
		observer : ObserverBase,
		scheduler : SchedulerBase = null
	) -> DisposableBase:
		var at_end = RefValue.Set(false)
		var has_value = RefValue.Set(false)
		var value = RefValue.Null()
		
		var sample_subscribe = func(__ = null):
			if has_value.v:
				has_value.v = false
				observer.on_next(value.v)
			
			if at_end.v:
				observer.on_completed()
		
		var on_next = func(new_value):
			has_value.v = true
			value.v = new_value
		
		var on_completed = func():
			at_end.v = true
		
		return CompositeDisposable.new([
			source.subscribe(
				on_next, observer.on_error, on_completed,
				scheduler
			),
			sampler.subscribe(
				sample_subscribe,
				observer.on_error,
				sample_subscribe,
				scheduler
			)
		])
	
	return Observable.new(subscribe)

static func sample_(
	sampler : Observable,
	sampler_time : float = NAN,
	scheduler : SchedulerBase = null
) -> Callable:
#	"""Samples the observable sequence at each interval.
#
#		Examples:
#			>>> var res = sample.call(source)
#
#		Args:
#			source: Source sequence to sample.
#
#		Returns:
#			Sampled observable sequence.
#		"""
	var sample = func(source : Observable) -> Observable:
		if sampler_time != NAN:
			return sample_observable(
				source, GDRx.obs.interval(sampler_time, scheduler)
			)
		else:
			return sample_observable(source, sampler)
	
	return sample
