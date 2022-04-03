extends AnimatedSprite

export var death_ray_scene: PackedScene
export var laser_scene: PackedScene
export var rocket_scene: PackedScene
export var shotgun_scene: PackedScene

var type = -1
var angular_speed = 0
var shot_delay = 1000

var counter = 0

const DEATH_RAY = 0
const LASER = 1
const ROCKET = 2
const SHOTGUN = 3

const ANGULAR_SPEEDS = {
	DEATH_RAY: 0.05,
	LASER: 0.02,
	ROCKET: 0.2,
	SHOTGUN: 0.2
}

const SHOT_DELAYS = {
	DEATH_RAY: 1,
	LASER: 200,
	ROCKET: 1,
	SHOTGUN: 1
}

func setup(gun_type):
	type = gun_type
	angular_speed = ANGULAR_SPEEDS[type]
	shot_delay = SHOT_DELAYS[type]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	# self.offset.x = -get_parent().in_node[0]
	# self.offset.y = -get_parent().in_node[1]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = get_node("/root/root/player_ship")
	var target_rotation = player.global_position.angle_to_point(self.global_position)
	
	# todo: fix weird rotation issue
	var delta_angle = self.global_rotation - target_rotation
	if abs(delta_angle) < angular_speed:
		self.global_rotation = target_rotation
	else:
		if Globals.norm_angle_rad(delta_angle) > deg2rad(180):
			self.global_rotation += angular_speed
		else:
			self.global_rotation -= angular_speed
	
	counter += 1
	if counter >= shot_delay:
		counter = 0
		if type == DEATH_RAY:
			pass
		elif type == SHOTGUN:
			pass
		elif type == LASER:
			var shot = laser_scene.instance()
			shot.global_position = self.global_position
			shot.global_rotation = self.global_rotation
			get_tree().root.add_child(shot)
		elif type == ROCKET:
			pass
		else:
			pass
