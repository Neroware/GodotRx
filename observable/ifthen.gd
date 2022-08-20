## Determines whether an observable collection contains values.
## [br]
##    Example:
## [codeblock]
##    1 - var res = GDRx.obs.if_then(condition, obs1)
##    2 - var res = GDRx.obs.if_then(condition, obs1, obs2)
## [/codeblock]
## [br]
##    Args:
## [br]
##        -> condition: The condition which determines if the then_source or
##            else_source will be run.
## [br]
##        -> then_source: The observable sequence or Promise that
##            will be run if the condition function returns true.
## [br]
##        -> else_source: [Optional] The observable sequence or
##            Promise that will be run if the condition function returns
##            False. If this is not provided, it defaults to
##            GDRx.obs.empty()
## [br][br]
##    Returns:
## [br]
##        An observable sequence which is either the then_source or
##        else_source.
static func if_then_(
	then_source : Observable,
	else_source : Observable = null,
	condition : Callable = func() -> bool: return true
) -> Observable:
	
	var else_source_ = else_source if else_source != null else GDRx.obs.empty()
	
	var factory = func(__ : SchedulerBase) -> Observable:
		return then_source if condition.call() else else_source_
	
	return GDRx.obs.defer(factory)
