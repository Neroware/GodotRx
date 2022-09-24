static func multicast_(
	subject : SubjectBase = null,
	subject_factory = null,
	mapper = null
) -> Callable:
	
	"""Multicasts the source sequence notifications through an
	instantiated subject into all uses of the sequence within a mapper
	function. Each subscription to the resulting sequence causes a
	separate multicast invocation, exposing the sequence resulting from
	the mapper function's invocation. For specializations with fixed
	subject types, see Publish, PublishLast, and Replay.

	Examples:
		>>> var res = GDRx.op.multicast(observable)
		>>> var res = GDRx.op.multicast(
			null,
			func(scheduler): Subject.new(),
			func(x): return x
		)

	Args:
		subject_factory: Factory function to create an intermediate
			subject through which the source sequence's elements will be
			multicast to the mapper function.
		subject: Subject to push source elements into.
		mapper: [Optional] Mapper function which can use the
			multicasted source sequence subject to the policies enforced
			by the created subject. Specified only if subject_factory
			is a factory function.

	Returns:
		An observable sequence that contains the elements of a sequence
		produced by multicasting the source sequence within a mapper
		function.
	"""
	
	var multicast = func(source : Observable) -> Observable:
		if subject_factory != null:
			
			var subscribe = func(
				observer : ObserverBase,
				scheduler : SchedulerBase = null
			) -> DisposableBase:
				assert(subject_factory is Callable)
				var connectable = source.pipe1(
					GDRx.op.multicast(subject_factory.call(scheduler))
				)
				assert(mapper is Callable)
				var subscription = mapper.call(connectable).subscribe(
					observer, func(e):return, func():return,
					scheduler
				)
				
				return CompositeDisposable.new([
					subscription, connectable.connect(scheduler)
				])
			
			return Observable.new(subscribe)
		
		if subject == null:
			GDRx.exc.NullReferenceException.new().throw()
		var ret = ConnectableObservable.new(source, subject)
		return ret
	
	return multicast
