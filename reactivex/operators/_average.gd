class AverageValue:
	var sum : float
	var count : int
	func _init(sum, count):
		self.sum = sum
		self.count = count

static func average_(
	key_mapper = null
) -> Callable:
	var average = func(source : Observable) -> Observable:
		var key_mapper_ : Callable = key_mapper if key_mapper != null else func(x): return float(x)
		
		var accumulator = func(prev : AverageValue, curr : float) -> AverageValue:
			return AverageValue.new(prev.sum + curr, prev.count + 1)
		
		var mapper = func(s : AverageValue) -> float:
			if s.count == 0:
				push_error("Input Sequence was empty!")
				return NAN
			
			return s.sum / float(s.count)
		
		var seed = AverageValue.new(0, 0)
		
		var ret = source.pipe4(
			GDRx.op.map(key_mapper_),
			GDRx.op.scan(accumulator, seed),
			GDRx.op.last(),
			GDRx.op.map(mapper)
		)
		return ret
	
	return average
