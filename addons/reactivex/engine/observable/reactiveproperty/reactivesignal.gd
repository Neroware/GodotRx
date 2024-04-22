extends ReactiveSignalBase
class_name ReactiveSignal

const MAX_ARGS : int = 8

signal _signal0
signal _signal1(arg0)
signal _signal2(arg0, arg1)
signal _signal3(arg0, arg1, arg2)
signal _signal4(arg0, arg1, arg2, arg3)
signal _signal5(arg0, arg1, arg2, arg3, arg4)
signal _signal6(arg0, arg1, arg2, arg3, arg4, arg5)
signal _signal7(arg0, arg1, arg2, arg3, arg4, arg5, arg6)
signal _signal8(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7)

var is_disposed : bool

var _signal : Signal
var _n_args : int
var _observers : Array[ObserverBase]
var _connections : Array[Callable]

func _init(n_args : int = 1):
	if n_args > MAX_ARGS:
		GDRx.raise(TooManyArgumentsError.new(
			"Only up to 8 signal parameters supported! Use lists instead!"))
		super._init(func(__, ___ = null): return Disposable.new())
		return
	
	self.is_disposed = false
	
	self._n_args = n_args
	self._observers = []
	match self._n_args:
		0: self._signal = self._signal0
		1: self._signal = self._signal1
		2: self._signal = self._signal2
		3: self._signal = self._signal3
		4: self._signal = self._signal4
		5: self._signal = self._signal5
		6: self._signal = self._signal6
		7: self._signal = self._signal7
		8: self._signal = self._signal8
		_: assert(false) # "should not happen"
	
	var wself = weakref(self)
	
	var subscribe_ = func(observer : ObserverBase, scheduler_ : SchedulerBase = null) -> DisposableBase:
		var rself : ReactiveSignal = wself.get_ref()
		if rself == null:
			return Disposable.new()
		
		var scheduler : GodotSignalScheduler = scheduler_ if scheduler_ is GodotSignalScheduler else GodotSignalScheduler.singleton()
		
		rself._observers.push_back(observer)
		var on_dispose = func():
			var _rself : ReactiveSignal = wself.get_ref()
			if _rself == null:
				return
			_rself._observers.erase(observer)
		
		var action : Callable
		match n_args:
			0:
				action = func():
					observer.on_next(Tuple.new([]))
			1:
				action = func(arg1):
					if arg1 is Array:
						observer.on_next(Tuple.new(arg1))
					else:
						observer.on_next(arg1)
			2:
				action = func(arg1, arg2):
					observer.on_next(Tuple.new([arg1, arg2]))
			3:
				action = func(arg1, arg2, arg3):
					observer.on_next(Tuple.new([arg1, arg2, arg3]))
			4:
				action = func(arg1, arg2, arg3, arg4):
					observer.on_next(Tuple.new([arg1, arg2, arg3, arg4]))
			5:
				action = func(arg1, arg2, arg3, arg4, arg5):
					observer.on_next(Tuple.new([arg1, arg2, arg3, arg4, arg5]))
			6:
				action = func(arg1, arg2, arg3, arg4, arg5, arg6):
					observer.on_next(Tuple.new([arg1, arg2, arg3, arg4, arg5, arg6]))
			7:
				action = func(arg1, arg2, arg3, arg4, arg5, arg6, arg7):
					observer.on_next(Tuple.new([arg1, arg2, arg3, arg4, arg5, arg6, arg7]))
			8:
				action = func(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8):
					observer.on_next(Tuple.new([arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8]))
			_:
				GDRx.raise(TooManyArgumentsError.new(
					"Only up to 8 signal parameters supported! Use lists instead!"))
				return Disposable.new()
		
		var sub = scheduler.schedule_signal(rself._signal, rself._n_args, action)
		var cd = CompositeDisposable.new([sub, Disposable.new(on_dispose)])
		return cd
	
	super._init(subscribe_)

func _emit(args = []):
	if self.is_disposed:
		return
	
	var args_ = []
	GDRx.iter(args).foreach(func(arg):
		args_.push_back(arg))
	
	match self._n_args:
		0: self._signal.emit()
		1: self._signal.emit(args_[0])
		2: self._signal.emit(args_[0], args_[1])
		3: self._signal.emit(args_[0], args_[1], args_[2])
		4: self._signal.emit(args_[0], args_[1], args_[2], args_[3])
		5: self._signal.emit(args_[0], args_[1], args_[2], args_[3], args_[4])
		6: self._signal.emit(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5])
		7: self._signal.emit(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6])
		8: self._signal.emit(args_[0], args_[1], args_[2], args_[3], args_[4], args_[5], args_[6], args_[7])
		_: assert(false) # "should not happen"

func attach(cb : Callable):
	if self.is_disposed:
		return
	if not cb in self._connections:
		self._signal.connect(cb)
		self._connections.push_back(cb)

func detach(cb : Callable):
	if self.is_disposed:
		return
	if cb in self._connections:
		self._signal.disconnect(cb)
		self._connections.erase(cb)

func dispose():
	if this.is_disposed:
		return
	this.is_disposed = true
	
	for observer in this._observers:
		observer.on_completed()
	for conn in this._connections:
		self._signal.disconnect(conn)
