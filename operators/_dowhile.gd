static func do_while_(
	condition : Callable
) -> Callable:
	
	var do_while = func(source : Observable) -> Observable:
		return source.pipe1(
			GDRx.pipe.concat1(
				source.pipe1(
					GDRx.op.while_do(condition)
				)
			)
		)
	
	return do_while
