extends Node2D

signal block_destroyed

export var main_block_scene: PackedScene
export var split_block_scene: PackedScene
export var line_block_scene: PackedScene
export var gun_block_scene: PackedScene
export var small_explosion_scene: PackedScene

var main_block
var main_block_ref

var rng = RandomNumberGenerator.new()

var countdown = 120.0
var display_countdown = countdown

var score = 0
var display_score = score

func add_block(source_block, new_block_scene, source_node_idx):
	var new_block = new_block_scene.instance()
	if new_block is GunBlock:
		new_block.setup(rng.randi_range(0,Globals.SHOT_COUNT-1))
		# new_block.setup(Globals.ROCKET)
	source_block.add_child(new_block)
	add_to_group("blocks")
	var node = source_block.out_nodes[source_node_idx]
	new_block.position = Vector2(node[0], node[1])
	var left_side = Globals.norm_angle_degree(source_block.global_rotation_degrees + 90) >= 180
	var front = Globals.norm_angle_degree(source_block.global_rotation_degrees) == 90
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
	if main_block_ref and main_block_ref.get_ref():
		main_block.free()
	main_block = main_block_scene.instance()
	main_block_ref = weakref(main_block)
	main_block.position = Vector2(320, -110)
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

func is_block(block):
	return block is LineBlock or block is SplitBlock or block is GunBlock
		

func get_all_child_blocks(block):
	var blocks = [block]
	for child in block.get_children():
		if is_block(child):
			blocks += get_all_child_blocks(child)
	return blocks
			

func handle_hit(shot, block):
	# prevent shots from hitting twice
	if !shot.hot:
		return
		
	var relevant_blocks = get_all_child_blocks(block)
	
	if Globals.state == Globals.STATE_FIGHT:
		var total_health = 0
		for block in relevant_blocks:
			total_health += block.health
		for block in relevant_blocks:
			var damage = 1
			block.health *= (1 - damage/total_health*Globals.GROUP_BONUS_DAMAGE_MULTIPLIER)
	
	shot.hot = false
	shot.queue_free()
	if block.health <= 0:
		emit_signal("block_destroyed")
		#
		# TODO: cascade explosions down and calculate score accordingly
		#
		if block is MainBlock:
			score += 500
		else:
			score += 100
		var explosion = small_explosion_scene.instance()
		explosion.position = block.global_position
		add_child(explosion)
		explosion.emitting = true
		block.free()

func free_emitters():
	for emitter in get_tree().get_nodes_in_group("one_shot_emitters"):
		if not emitter.emitting:
			emitter.queue_free()	
	
func lerp_countdown():
	var delta = countdown - display_countdown
	if abs(delta) < 1:
		display_countdown = countdown
	else:
		display_countdown += 0.2 * delta / abs(delta)
	get_node("canvas/countdown_label").text = str(display_countdown).pad_decimals(2)

func lerp_score():
	var delta = score - display_score
	if abs(delta) < 1:
		display_score = score
	else:
		display_score += 10 * delta / abs(delta)
	get_node("canvas/score_label").set_text(str(display_score))

func handle_ui_keys():
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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if Globals.state == Globals.STATE_INIT_BEGIN:
		create_random_boss()
		get_node("canvas/bonus_label").visible = false
		Globals.state = Globals.STATE_INIT
	elif Globals.state in [Globals.STATE_INIT]:
			if main_block.position.y < 110:
				main_block.position.y += 2
	elif Globals.state in [Globals.STATE_FIGHT]:
		countdown -= delta
		if not main_block_ref.get_ref():
			Globals.state = Globals.STATE_BOSS_DEFEATED
			get_node("canvas/bonus_label").visible = true
			countdown += 20

	lerp_score()
	lerp_countdown()
	handle_ui_keys()
	free_emitters()

