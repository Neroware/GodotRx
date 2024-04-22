class AverageValue:
	var sum : float
	var count : int
	func _init(sum_, count_):
		self.sum = sum_
		self.count = count_

static func average_(
	key_mapper = null
) -> Callable:
	var average = func(source : Observable) -> Observable:
#		"""Partially applied average operator.
#
#		Computes the average of an observable sequence of values that
#		are in the sequence or obtained by invoking a transform
#		function on each element of the input sequence if present.
#
#		Examples:
#			>>> var res = average.call(source)
#
#		Args:
#			source: Source observable to average.
#
#		Returns:
#			An observable sequence containing a single element with the
#			average of the sequence of values.
#		"""
		@warning_ignore("incompatible_ternary")
		var key_mapper_ : Callable = key_mapper if key_mapper != null else func(x): return float(x)
		
		var accumulator = func(prev : AverageValue, curr : float) -> AverageValue:
			return AverageValue.new(prev.sum + curr, prev.count + 1)
		
		var mapper = func(s : AverageValue) -> float:
			if s.count == 0:
				BadMappingError.new("Input Sequence was empty!").throw()
				return NAN
			
			return s.sum / float(s.count)
		
		var seed_ = AverageValue.new(0, 0)
		
		var ret = source.pipe4(
			GDRx.op.map(key_mapper_),
			GDRx.op.scan(accumulator, seed_),
			GDRx.op.last(),
			GDRx.op.map(mapper)
		)
		return ret
	
	return average
