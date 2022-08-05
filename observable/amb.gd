static func amb_(sources : Array[Observable]) -> Observable:
	
	var acc : Observable = GDRx.obs.never()
	
	var fun = func(previous : Observable, current : Observable) -> Observable:
		return GDRx.op.amb(previous).call(current)
	
	for source in sources:
		acc = fun.call(acc, source)
	
	return acc
