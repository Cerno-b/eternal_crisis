extends Area2D

const SPEED = 2
const ANGULAR_SPEED = 0.02

# export var player_node: NodePath

var lifetime = 500
var health = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = get_node("/root/root/player_ship")
	
	var target_rotation = player.global_position.angle_to_point(self.global_position)
	if Globals.norm_angle_rad(self.global_rotation - target_rotation) > deg2rad(180):
		self.rotation += ANGULAR_SPEED
	else:
		self.rotation -= ANGULAR_SPEED
	
	self.position += Vector2(1,0).rotated(self.rotation) * SPEED
	
	lifetime -= 1
	if lifetime <= 0:
		self.queue_free()
