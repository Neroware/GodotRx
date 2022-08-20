## Propagates the observable sequence that reacts first.
##    [br]
##    Example:
##    [codeblock]
##    var winner = GDRx.obs.amb([xs, ys, zs])
##    [/codeblock]
##    [br]
##    Returns:
##    [br]
##    An observable sequence that surfaces any of the given sequences,
##    whichever reacted first.
static func amb_(sources : Array[Observable]) -> Observable:
	
	var acc : Observable = GDRx.obs.never()
	
	var fun = func(previous : Observable, current : Observable) -> Observable:
		return GDRx.op.amb(previous).call(current)
	
	for source in sources:
		acc = fun.call(acc, source)
	
	return acc
