extends AnimatedSprite

export var death_ray_scene: PackedScene
export var laser_scene: PackedScene
export var rocket_scene: PackedScene
export var shotgun_scene: PackedScene

var type = -1
var angular_speed = 0
var shot_delay_list = []

var counter = 0
var shot_stage = 0

var death_ray_obj

const ANGULAR_SPEEDS = {
	Globals.DEATH_RAY: 0.005,
	Globals.LASER: 0.02,
	Globals.ROCKET: 0.2,
	Globals.SHOTGUN: 0.2
}

const SHOT_DELAY_LISTS = {
	Globals.DEATH_RAY: [50, 50, 100, 50],
	Globals.LASER: [200, 20, 20],
	Globals.ROCKET: [1],
	Globals.SHOTGUN: [1]
}

func setup(gun_type):
	type = gun_type
	angular_speed = ANGULAR_SPEEDS[type]
	shot_delay_list = SHOT_DELAY_LISTS[type]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	# self.offset.x = -get_parent().in_node[0]
	# self.offset.y = -get_parent().in_node[1]

func fire_laser():
	var shot = laser_scene.instance()
	shot.global_position = self.global_position
	shot.global_rotation = self.global_rotation
	get_tree().root.add_child(shot)
	
func fire_death_ray(stage):
	if stage == 0:
		death_ray_obj = death_ray_scene.instance()
		#death_ray_obj.global_position = self.global_position
		#death_ray_obj.global_rotation = self.global_rotation
		death_ray_obj.get_node("death_ray_sprite").animation = "aim"
		add_child(death_ray_obj)
	if stage == 1:
		death_ray_obj.get_node("death_ray_sprite").animation = "shoot"
	if stage == 2:
		death_ray_obj.get_node("death_ray_sprite").animation = "aim"
	if stage == 3:
		death_ray_obj.free()
		death_ray_obj = null
	

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
	if counter >= shot_delay_list[shot_stage]:
		if type == Globals.DEATH_RAY:
			fire_death_ray(shot_stage)
		elif type == Globals.SHOTGUN:
			pass
		elif type == Globals.LASER:
			fire_laser()
		elif type == Globals.ROCKET:
			pass
		else:
			pass
		
		counter = 0
		shot_stage = (shot_stage + 1) % len(shot_delay_list)
		
	#if death_ray_obj:
#		death_ray_obj.global_position = self.global_position
		#death_ray_obj.global_rotation = self.global_rotation

