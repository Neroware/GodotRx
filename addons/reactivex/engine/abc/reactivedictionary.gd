extends ReadOnlyReactiveDictionaryBase
class_name ReactiveDictionaryBase

func clear():
	NotImplementedError.raise()

func erase(key) -> bool:
	NotImplementedError.raise()
	return false

func set_pair(key, value):
	NotImplementedError.raise()
