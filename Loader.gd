extends Node

export(String, FILE, "*.*scn") var main_scene

var loader
var time_max = 1

func _ready():
	set_process(false)
	loader = ResourceLoader.load_interactive(main_scene)
	
	if loader != null:
		set_process(true)

func _process(time):
	if loader == null:
		set_process(false)
		return
	
	var t = OS.get_ticks_msec()
	var last_tick = t
	
	while OS.get_ticks_msec() < t + time_max:
		var err = loader.poll()
		print("Poll time: ", OS.get_ticks_msec() - last_tick)
		last_tick = OS.get_ticks_msec()
		
		if err == ERR_FILE_EOF: # Done loading all stages
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
		elif err == OK: # Done loadig current stage
			pass
		else:
			loader = null
			break

func set_new_scene(scene_resource):
	var current_scene = scene_resource.instance()
	
	get_node("/root").add_child(current_scene)
	Engine.get_main_loop().set_current_scene(current_scene)