extends Area2D

export var ShotScene: PackedScene

const SPEED = 4

const SHOT_GAP = 3
var shot_gap_counter = 0

var hidden = false
var invincible = false
var invincible_time = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	self.position = Vector2(320, 300)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

		
	var mouse_pos = get_global_mouse_position()
	var player_pos = self.global_position
	self.rotation = mouse_pos.angle_to_point(player_pos)

	if Input.is_action_pressed("ui_left") and self.position.x > 0:
		self.position.x -= SPEED
	if Input.is_action_pressed("ui_right") and self.position.x < get_viewport().size.x:
		self.position.x += SPEED
	if Input.is_action_pressed("ui_up") and self.position.y > 0:
		self.position.y -= SPEED
	if Input.is_action_pressed("ui_down") and self.position.y < get_viewport().size.y:
		self.position.y += SPEED
	
	shot_gap_counter += 1
	if shot_gap_counter >= SHOT_GAP:
		shot_gap_counter = 0
		
	if Input.is_action_pressed("ui_fire") and shot_gap_counter == 0 and visible:
		var shot = ShotScene.instance()
		shot.position = self.position
		shot.rotation = self.rotation
		self.get_parent().add_child(shot)
