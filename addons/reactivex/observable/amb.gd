## Propagates the observable sequence that reacts first.
##    [br]
##    [b]Example:[/b]
##    [codeblock]
##    var winner = GDRx.obs.amb([xs, ys, zs])
##    [/codeblock]
##    [br]
##    [b]Returns:[/b]
##    [br]
##    An observable sequence that surfaces any of the given sequences,
##    whichever reacted first.
static func amb_(sources_) -> Observable:
	var sources : Array[Observable] = GDRx.util.unpack_arg(sources_)
	
	var acc : Observable = GDRx.obs.never()
	
	var fun = func(previous : Observable, current : Observable) -> Observable:
		return GDRx.op.amb(previous).call(current)
	
	for source in sources:
		acc = fun.call(acc, source)
	
	return acc
