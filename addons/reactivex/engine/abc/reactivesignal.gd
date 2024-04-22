extends Observable
class_name ReactiveSignalBase

var this

func _init(subscribe_ : Callable):
	this = self
	this.unreference()
	
	super._init(subscribe_)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		this.dispose()

func _emit(_args = []):
	NotImplementedError.raise()

func attach(_cb : Callable):
	NotImplementedError.raise()

func detach(_cb : Callable):
	NotImplementedError.raise()

func emit():
	self._emit()
func emit0():
	self._emit([])
func emit1(arg0):
	self._emit([arg0])
func emit2(arg0, arg1):
	self._emit([arg0, arg1])
func emit3(arg0, arg1, arg2):
	self._emit([arg0, arg1, arg2])
func emit4(arg0, arg1, arg2, arg3):
	self._emit([arg0, arg1, arg2, arg3])
func emit5(arg0, arg1, arg2, arg3, arg4):
	self._emit([arg0, arg1, arg2, arg3, arg4])
func emit6(arg0, arg1, arg2, arg3, arg4, arg5):
	self._emit([arg0, arg1, arg2, arg3, arg4, arg5])
func emit7(arg0, arg1, arg2, arg3, arg4, arg5, arg6):
	self._emit([arg0, arg1, arg2, arg3, arg4, arg5, arg6])
func emit8(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7):
	self._emit([arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7])
func emit_unit():
	self._emit([StreamItem.Unit()])

func dispose():
	NotImplementedError.raise()
