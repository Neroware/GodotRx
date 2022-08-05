static func pluck_(key) -> Callable:
	var mapper = func(x : Dictionary):
		return x[key]
	
	return GDRx.op.map(mapper)

static func pluck_attr_(prop : String) -> Callable:
	return GDRx.op.map(func(x): return x.get(prop))
