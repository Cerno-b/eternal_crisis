extends Node2D


export var main_block_scene: PackedScene #load("res://scenes/main_block.tscn")
export var split_block_scene: PackedScene #load("res://scenes/split_block.tscn")
export var line_block_scene: PackedScene #load("res://scenes/line_block.tscn")
export var gun_block_scene: PackedScene #load("res://scenes/gun_block.tscn")

var main_block

var rng = RandomNumberGenerator.new()

func norm_angle(angle_deg):
	while angle_deg < 0:
		angle_deg += 360
	while angle_deg >= 360:
		angle_deg -= 360
	return angle_deg
		

func add_block(source_block, new_block_scene, source_node_idx):
	var new_block = new_block_scene.instance()
	source_block.add_child(new_block)
	add_to_group("blocks")
	var node = source_block.out_nodes[source_node_idx]
	new_block.position = Vector2(node[0], node[1])
	var left_side = norm_angle(source_block.global_rotation_degrees + 90) >= 180
	var front = norm_angle(source_block.global_rotation_degrees) == 90
	if source_block is LineBlock and front:
		new_block.rotation_degrees = 0
	elif source_block is LineBlock and left_side:
		new_block.rotation_degrees = -node[2]
	else:
		new_block.rotation_degrees = node[2]
	return new_block

var S = 0
var L = 1
var G = 2

func create_blocks_from_definition(source_block, definition, source_node_idx):
	if definition[0] == G:
		add_block(source_block, gun_block_scene, source_node_idx)
	elif definition[0] == L:
		var new_block = add_block(source_block, line_block_scene, source_node_idx)
		create_blocks_from_definition(new_block, definition[1], 0)
	elif definition[0] == S:
		var new_block = add_block(source_block, split_block_scene, source_node_idx)
		create_blocks_from_definition(new_block, definition[1], 0)
		create_blocks_from_definition(new_block, definition[2], 1)
		
func create_random_definition_rec(current_depth, target_depth):
	if current_depth + 1 == target_depth:
		return [G]
	var r = rng.randi_range(0, 3)
	var def = []
	if r == 0:
		def = [G]
	elif r in [1,2]:
		def = [L, create_random_definition_rec(current_depth+1, target_depth)]
	elif r == 3:
		def = [S, 
				create_random_definition_rec(current_depth+1, target_depth), 
				create_random_definition_rec(current_depth+1, target_depth)]
	return def
	
		
func create_random_definition(depth):
	var definition = create_random_definition_rec(0, depth)
	return definition

func create_random_boss():
	if main_block:
		main_block.free()
	main_block = main_block_scene.instance()
	main_block.position = Vector2(320, 110)
	add_child(main_block)
	
	var gun = [G]
	var line_gun = [L, gun]
	var line_gun_2 = [L, line_gun]
	var split_line_gun = [S, line_gun_2, line_gun_2]
	var definition = split_line_gun
	
	var depth = 5
	definition = create_random_definition(depth)
	create_blocks_from_definition(main_block, definition, 0)
	definition = create_random_definition(depth)
	create_blocks_from_definition(main_block, definition, 1)
	definition = create_random_definition(depth)
	create_blocks_from_definition(main_block, definition, 2)

func handle_hit(shot, block):
	pass
			
		

# Called when the node enters the scene tree for the first time.
func _ready():
	create_random_boss()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
		
	if Input.is_action_just_pressed("ui_page_up"):
		create_random_boss()
	if Input.is_action_just_pressed("ui_scaling_1x"):
		OS.set_window_size(Vector2(640, 360))
	if Input.is_action_just_pressed("ui_scaling_2x"):
		OS.set_window_size(Vector2(1280, 720))
	if Input.is_action_just_pressed("ui_scaling_fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		
	# handle_shots()
