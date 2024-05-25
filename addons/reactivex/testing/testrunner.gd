extends Node
class_name __GDRx_TestRunner__

@export var tests_directory : String = "res://addons/reactivex/testing/tests"

func _ready():
	await self._run_tests_in_directory(tests_directory)
	print("[ReactiveX]: All tests completed.")
	get_tree().quit()

func _run_tests_in_directory(directory: String):
	var dir_access = DirAccess.open(directory)
	if dir_access:
		dir_access.list_dir_begin()
		var file_name = dir_access.get_next()
		while file_name != "":
			if file_name != "." and file_name != "..":
				var file_path = directory + "/" + file_name
				if dir_access.current_is_dir():
					self._run_tests_in_directory(file_path)
				elif file_name.ends_with(".test.gd"):
					var test_script = load(file_path)
					var test_instance = test_script.new()
					await test_instance.run_tests()
			file_name = dir_access.get_next()
		dir_access.list_dir_end()
