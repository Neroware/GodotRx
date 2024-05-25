class_name ObservableAwait

signal _on_next(item : Variant)
signal _on_error(error : Variant)
signal _on_completed()

func on_next(obs : Observable) -> Variant:
	var fired_item = RefValue.Set(GDRx.NOT_SET)
	
	var on_next_ = func(i):
		fired_item.v = i
		self._on_next.emit(i)
	
	var __ = obs.take(1).subscribe(on_next_)
	
	if not GDRx.not_set(fired_item.v):
		return fired_item.v
	var i = await self._on_next
	return i

func on_error(obs : Observable) -> Variant:
	var fired_error = RefValue.Set(GDRx.NOT_SET)
	
	var on_error_ = func(e):
		fired_error.v = e
		self._on_error.emit(e)
	
	var __ = obs.subscribe3(on_error_)
	
	if not GDRx.not_set(fired_error.v):
		return fired_error.v
	var e = await self._on_error
	return e

func on_completed(obs : Observable):
	var fired_complete = RefValue.Set(false)
	
	var on_completed_ = func():
		fired_complete.v = true
		self._on_completed.emit()
	
	var __ = obs.subscribe4(on_completed_)
	
	if fired_complete.v:
		return
	await self._on_completed
	return
