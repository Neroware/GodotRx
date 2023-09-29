static func do_while_(
	condition : Callable
) -> Callable:
#	"""Repeats source as long as condition holds emulating a do while
#	loop.
#
#	Args:
#		condition: The condition which determines if the source will be
#			repeated.
#
#	Returns:
#		An observable sequence which is repeated as long
#		as the condition holds.
#	"""
	var do_while = func(source : Observable) -> Observable:
		return source.pipe1(
			GDRx.op.concat([
				source.pipe1(
					GDRx.op.while_do(condition)
				) as Observable
			])
		)
	
	return do_while
