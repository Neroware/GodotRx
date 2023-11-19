## Generates an observable sequence that repeats the given element
##    the specified number of times.
## [br]
##    [b]Examples:[/b]
##        [codeblock]
##        1 - var res = GDRx.obs.repeat_value(42)
##        2 - var res = GDRx.obs.repeat_value(42, 4)
##        [/codeblock]
## [br]
##    [b]Args:[/b]
## [br]
##        [code]value[/code] Element to repeat.
## [br]
##        [code]repeat_count[/code] [Optional] Number of times to repeat the element.
##            If not specified, repeats indefinitely.
## [br][br]
##    [b]Returns:[/b]
## [br]
##        An observable sequence that repeats the given element the
##        specified number of times.
static func repeat_value_(value, repeat_count = null) -> Observable:
	
	if repeat_count == -1:
		repeat_count = null
	
	var xs : Observable = GDRx.obs.return_value(value)
	return xs.pipe1(GDRx.op.repeat(repeat_count))
