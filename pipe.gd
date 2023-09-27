func reduce(fun : Callable, iterable : IterableBase, initial = GDRx.util.NOT_SET):
	var it = iterable.iter()
	var next_ = it.next()
	var value_ = initial
	while not next_ is ItEnd:
		value_ = fun.call(value_, next_)
		next_ = it.next()
	return value_

func compose1(__op1 : Callable) -> Callable:
	return compose(GDRx.util.Iter([__op1]))

func compose2(__op1 : Callable, __op2 : Callable) -> Callable:
	return compose(GDRx.util.Iter([__op1, __op2]))

func compose3(
	__op1 : Callable, 
	__op2 : Callable,
	__op3 : Callable
) -> Callable:
	return compose(GDRx.util.Iter([__op1, __op2, __op3]))

func compose4(
	__op1 : Callable, 
	__op2 : Callable,
	__op3 : Callable,
	__op4 : Callable
) -> Callable:
	return compose(GDRx.util.Iter([__op1, __op2, __op3, __op4]))

func compose5(
	__op1 : Callable, 
	__op2 : Callable,
	__op3 : Callable,
	__op4 : Callable,
	__op5 : Callable
) -> Callable:
	return compose(GDRx.util.Iter([__op1, __op2, __op3, __op4, __op5]))

func compose6(
	__op1 : Callable, 
	__op2 : Callable,
	__op3 : Callable,
	__op4 : Callable,
	__op5 : Callable,
	__op6 : Callable
) -> Callable:
	return compose(GDRx.util.Iter([__op1, __op2, __op3, __op4, __op5, __op6]))

func composea(operators : Array[Callable]) -> Callable:
	return compose(GDRx.util.Iter(operators))

## Compose multiple operators left to right.
## Composes zero or more operators into a functional composition. The
## operators are composed to left to right. A composition of zero
## operators gives back the source.
## [br]
## [b]Examples:[/b]
##    [codeblock]
##    pipe0().call(source) == source
##    pipe1(f).call(source) == f.call(source)
##    pipe2(f, g).call(source) == g.call(f.call(source))
##    pipe3(f, g, h).call(source) == h.call(g.call(f.call(source)))
##    ...
##    [/codeblock]
## [br][br]
## [b]Returns:[/b]
## [br]
##    The composed observable.
func compose(operators : IterableBase) -> Callable:
	var _compose = func(source):
		return reduce(func(obs, op): return op.call(obs), operators, source)
	return _compose

func pipe0(_value) -> Variant:
	return pipe(_value, GDRx.util.Iter([]))

func pipe1(__value : Variant, __fn1 : Callable) -> Variant:
	return pipe(__value, GDRx.util.Iter([__fn1]))

func pipe2(
	__value : Variant, 
	__fn1 : Callable,
	__fn2 : Callable
) -> Variant:
	return pipe(__value, GDRx.util.Iter([__fn1, __fn2]))

func pipe3(
	__value : Variant, 
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable
) -> Variant:
	return pipe(__value, GDRx.util.Iter([__fn1, __fn2, __fn3]))

func pipe4(
	__value : Variant, 
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable
) -> Variant:
	return pipe(__value, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4]))

func pipe5(
	__value : Variant, 
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable,
	__fn5 : Callable
) -> Variant:
	return pipe(__value, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4, __fn5]))

func pipe6(
	__value : Variant, 
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable,
	__fn5 : Callable,
	__fn6 : Callable
) -> Variant:
	return pipe(__value, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4, __fn5, __fn6]))

func pipe7(
	__value : Variant, 
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable,
	__fn5 : Callable,
	__fn6 : Callable,
	__fn7 : Callable
) -> Variant:
	return pipe(__value, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4, __fn5, __fn6, __fn7]))

func pipe8(
	__value : Variant, 
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable,
	__fn5 : Callable,
	__fn6 : Callable,
	__fn7 : Callable,
	__fn8 : Callable
) -> Variant:
	return pipe(__value, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4, __fn5, __fn6, __fn7, __fn8]))

func pipe9(
	__value : Variant, 
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable,
	__fn5 : Callable,
	__fn6 : Callable,
	__fn7 : Callable,
	__fn8 : Callable,
	__fn9 : Callable
) -> Variant:
	return pipe(__value, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4, __fn5, __fn6, __fn7, __fn8, __fn9]))

func pipea(__value, arr : Array):
	return pipe(__value, GDRx.util.Iter(arr))

## Functional pipe (`|>`)
## [br]
## Allows the use of function argument on the left side of the
## function.
## [br]
## [b]Example:[/b]
##    [codeblock]
##    pipe2(x, fn) == __fn.call(x)  # Same as x |> fn
##    pipe3(x, fn, gn) == gn.call(fn.call(x))  # Same as x |> fn |> gn
##    ...
##    [/codeblock]
func pipe(__value : Variant, fns : IterableBase) -> Variant:
	return compose(fns).call(__value)
