class_name ObservableAwait

var _obs : Observable

signal _on_next(item : Variant)
signal _on_error(error : Variant)
signal _on_completed()

func _init(obs : Observable):
	self._obs = obs

func on_next() -> Variant:
	var fired_item = RefValue.Set(GDRx.NOT_SET)
	
	var on_next_ = func(i):
		fired_item.v = i
		self._on_next.emit(i)
		
	self._obs.take(1).subscribe(on_next_).dispose_with(self)
	if not GDRx.not_set(fired_item.v):
		return fired_item.v
	var i = await self._on_next
	return i

func on_error() -> Variant:
	var fired_error = RefValue.Set(GDRx.NOT_SET)
	
	var on_error_ = func(e):
		fired_error.v = e
		self._on_error.emit(e)
	
	self._obs.subscribe3(on_error_).dispose_with(self)
	if not GDRx.not_set(fired_error.v):
		return fired_error.v
	var e = await self._on_error
	return e

func on_completed():
	var fired_complete = RefValue.Set(false)
	
	var on_completed_ = func():
		fired_complete.v = true
		self._on_completed.emit()
	
	self._obs.subscribe4(on_completed_).dispose_with(self)
	if fired_complete.v:
		return
	await self._on_completed
	return
