extends Node2D

signal block_destroyed

export var main_block_scene: PackedScene
export var split_block_scene: PackedScene
export var line_block_scene: PackedScene
export var gun_block_scene: PackedScene
export var small_explosion_scene: PackedScene
export var large_explosion_scene: PackedScene

var main_block
var main_block_ref

var rng = RandomNumberGenerator.new()

var level = 1
var countdown = 120.0
var display_countdown = countdown

var display_score = Globals.score

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
		Globals.gun_count += 1
		return [G]
	var r = rng.randi_range(0, 3)
	var def = []
	if r == 0:
		Globals.gun_count += 1
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
	
	var best_definition_set = []
	var definition_set = []
	
	var side_depth = min(level, 10)
	var front_depth = min(level, 5)
	var target_gun_count = round(level*1.7)
	var best_delta = 10000
	for i in range(100):
		Globals.gun_count = 0
		var def_r = create_random_definition(side_depth)
		var def_f = create_random_definition(front_depth)
		var def_l = create_random_definition(side_depth)
		definition_set = [def_r, def_f, def_l]
		var delta = abs(Globals.gun_count - target_gun_count)
		if delta < best_delta:
			best_definition_set = definition_set
			best_delta = delta

	create_blocks_from_definition(main_block, best_definition_set[0], 0)
	create_blocks_from_definition(main_block, best_definition_set[1], 1)
	create_blocks_from_definition(main_block, best_definition_set[2], 2)

func is_block(block):
	return block is LineBlock or block is SplitBlock or block is GunBlock or block is MainBlock
		

func get_all_child_blocks(block):
	var blocks = [block]
	for child in block.get_children():
		if is_block(child):
			blocks += get_all_child_blocks(child)
	return blocks
			

func create_explosion(node):
	var explosion = large_explosion_scene.instance()
	explosion.position = node.global_position
	add_child(explosion)
	explosion.emitting = true
	

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
			var damage = 2 # 1
			block.health *= (1 - damage/total_health*Globals.GROUP_BONUS_DAMAGE_MULTIPLIER)
	
	shot.hot = false
	shot.queue_free()
	if block.health <= 0:
		emit_signal("block_destroyed")
		for child in get_all_child_blocks(block):
			if child is MainBlock:
				Globals.score += 500
				get_node("snd_core_dead").play()
			else:
				Globals.score += 100
				get_node("snd_block_dead").play()
			create_explosion(child)

		block.free()

func free_emitters():
	for emitter in get_tree().get_nodes_in_group("one_shot_emitters"):
		if not emitter.emitting:
			emitter.queue_free()	
			
func free_rockets():
	for rocket in get_tree().get_nodes_in_group("rockets"):
		if rocket.lifetime <= 0 or Globals.state == Globals.STATE_BOSS_DEFEATED:
			create_explosion(rocket)
			rocket.queue_free()
			
	
func lerp_countdown():
	var delta = countdown - display_countdown
	if abs(delta) < 1 or delta / abs(delta) < 0:
		display_countdown = countdown
	else:
		display_countdown += 0.3 * delta / abs(delta)
	get_node("canvas/countdown_label").text = str(display_countdown).pad_decimals(2)

func lerp_score():
	var delta = Globals.score - display_score
	if abs(delta) < 1:
		display_score = Globals.score
	else:
		display_score += 10 * delta / abs(delta)
	get_node("canvas/score_label").set_text(str(display_score))

func is_area_active_shot(area):
	if area is Rocket or area is Laser or area is Shotgun or area is DeathRay:
		return true
	return false

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	Globals.state = Globals.STATE_INIT_BEGIN
	Globals.score = 0
	display_score = Globals.score

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = get_node("player_ship")
	if Globals.state == Globals.STATE_INIT_BEGIN:
		create_random_boss()
		get_node("canvas/bonus_label").visible = false
		Globals.state = Globals.STATE_INIT
	elif Globals.state in [Globals.STATE_INIT]:
			if main_block.position.y < 110:
				main_block.position.y += 2
	elif Globals.state in [Globals.STATE_PLAYER_HIT_BEGIN]:
		player.hidden = true
		create_explosion(player)
		get_node("player_ship/snd_dead").play()
		get_node("canvas/malus_label").visible = true
		countdown -= 20
		Globals.state = Globals.STATE_PLAYER_HIT
	elif Globals.state == Globals.STATE_PLAYER_HIT:
		player.invincible_time = 50
	elif Globals.state in [Globals.STATE_PLAYER_HIT_END]:
		player.position = Vector2(320, 300)
		player.hidden = false
		Globals.state = Globals.STATE_FIGHT
		get_node("canvas/malus_label").visible = false
	elif Globals.state in [Globals.STATE_FIGHT]:
		countdown -= delta
		if main_block_ref != null and not main_block_ref.get_ref():
			Globals.state = Globals.STATE_BOSS_DEFEATED
			level += 1
			get_node("canvas/bonus_label").visible = true
			countdown += 40

	if Input.is_action_just_pressed("ui_page_up"):
		create_random_boss()
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene("res://scenes/title.tscn")

	lerp_score()
	lerp_countdown()
	free_emitters()
	free_rockets()
	
	player.invincible_time = max(player.invincible_time-1, 0)
	
	player.visible = !player.hidden
	if player.invincible_time % 4 != 0:
		player.visible = false
	player.invincible = false
	if player.invincible_time > 0:
		player.invincible = true
		
	if countdown < 0:
		get_tree().change_scene("res://scenes/game_over.tscn")
		

func _on_player_ship_area_entered(area):
	if get_node("player_ship").invincible:
		return
	if is_area_active_shot(area) or is_block(area):
		Globals.state = Globals.STATE_PLAYER_HIT_BEGIN
