## Determines whether an observable collection contains values.
## [br]
##    [b]Example:[/b]
## [codeblock]
##    1 - var res = GDRx.obs.if_then(condition, obs1)
##    2 - var res = GDRx.obs.if_then(condition, obs1, obs2)
## [/codeblock]
## [br]
##    [b]Args:[/b]
## [br]
##        [code]condition[/code] The condition which determines if the then_source or
##            else_source will be run.
## [br]
##        [code]then_source[/code] The observable sequence or Promise that
##            will be run if the condition function returns true.
## [br]
##        [code]else_source[/code] [Optional] The observable sequence or
##            Promise that will be run if the condition function returns
##            False. If this is not provided, it defaults to
##            [code]GDRx.obs.empty()[/code]
## [br][br]
##    [b]Returns:[/b]
## [br]
##        An observable sequence which is either the [code]then_source[/code] or
##        [code]else_source[/code].
static func if_then_(
	condition : Callable = GDRx.basic.default_condition,
	then_source : Observable = null,
	else_source : Observable = null
) -> Observable:
	
	var then_source_ = then_source if then_source != null else GDRx.obs.empty()
	var else_source_ = else_source if else_source != null else GDRx.obs.empty()
	
	var factory = func(__ : SchedulerBase) -> Observable:
		return then_source_ if condition.call() else else_source_
	
	return GDRx.obs.defer(factory)
