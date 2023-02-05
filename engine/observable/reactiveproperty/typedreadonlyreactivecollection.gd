extends ReadOnlyReactiveCollection
class_name ReadOnlyReactiveCollectionT

var _type
var T:
	get: return self._type

func _init(collection : ReactiveCollectionT):
	self._type = collection.T
	super._init(collection)
