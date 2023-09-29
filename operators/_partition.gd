static func partition_(
	predicate : Callable = GDRx.basic.default_condition
) -> Callable:
	
	var partition = func(source : Observable) -> Array[Observable]:
#		"""The partially applied `partition` operator.
#
#		Returns two observables which partition the observations of the
#		source by the given function. The first will trigger
#		observations for those values for which the predicate returns
#		true. The second will trigger observations for those values
#		where the predicate returns false. The predicate is executed
#		once for each subscribed observer. Both also propagate all
#		error observations arising from the source and each completes
#		when the source completes.
#
#		Args:
#			source: Source obserable to partition.
#
#		Returns:
#			A list of observables. The first triggers when the
#			predicate returns True, and the second triggers when the
#			predicate returns False.
#		"""
		var not_predicate = func(x) -> bool:
			return not predicate.call(x)
		
		var published = source.pipe2(
			GDRx.op.publish(),
			GDRx.op.ref_count()
		)
		return [
			published.pipe1(GDRx.op.filter(predicate)),
			published.pipe1(GDRx.op.filter(not_predicate))
		]
	
	return partition

static func partition_indexed_(
	predicate_indexed : Callable = GDRx.basic.default_condition
) -> Callable:
	
	var partition_indexed = func(source : Observable) -> Array[Observable]:
#		"""The partially applied indexed partition operator.
#
#		Returns two observables which partition the observations of the
#		source by the given function. The first will trigger
#		observations for those values for which the predicate returns
#		true. The second will trigger observations for those values
#		where the predicate returns false. The predicate is executed
#		once for each subscribed observer. Both also propagate all
#		error observations arising from the source and each completes
#		when the source completes.
#
#		Args:
#			source: Source observable to partition.
#
#		Returns:
#			A list of observables. The first triggers when the
#			predicate returns 'true', and the second triggers when the
#			predicate returns 'false'.
#		"""
		var not_predicate_indexed = func(x, i : int) -> bool:
			return not predicate_indexed.call(x, i)
		
		var published = source.pipe2(
			GDRx.op.publish(),
			GDRx.op.ref_count()
		)
		return [
			published.pipe1(GDRx.op.filter_indexed(predicate_indexed)),
			published.pipe1(GDRx.op.filter_indexed(not_predicate_indexed))
		]
	
	return partition_indexed
