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
	Globals.ROCKET: 0.002,
	Globals.SHOTGUN: 0.2
}

const SHOT_DELAY_LISTS = {
	Globals.DEATH_RAY: [80, 50, 80, 50],
	Globals.LASER: [200, 20, 20],
	Globals.ROCKET: [60],
	Globals.SHOTGUN: [50]
}

const SPRITE_NAMES = {
	Globals.DEATH_RAY: "death_ray",
	Globals.LASER: "laser",
	Globals.ROCKET: "rocket",
	Globals.SHOTGUN: "shotgun"
}

func setup(gun_type):
	type = gun_type
	angular_speed = ANGULAR_SPEEDS[type]
	shot_delay_list = SHOT_DELAY_LISTS[type]
	animation = SPRITE_NAMES[type]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func fire_laser():
	var shot = laser_scene.instance()
	shot.global_position = self.global_position
	shot.global_rotation = self.global_rotation
	get_node("/root/root").add_child(shot)
	var snd = get_node("/root/root/snd_laser")
	if not snd.playing:
		snd.play()
	
func fire_death_ray(stage):
	if stage == 0:
		death_ray_obj = death_ray_scene.instance()
		death_ray_obj.get_node("death_ray_sprite").animation = "aim"
		death_ray_obj.set_collision_mask_bit(3, false)
		add_child(death_ray_obj)
	if stage == 1:
		death_ray_obj.get_node("death_ray_sprite").animation = "shoot"
		death_ray_obj.set_collision_mask_bit(3, true)
		var snd = get_node("/root/root/snd_death_ray")
		if not snd.playing:
			snd.play()

	if stage == 2:
		death_ray_obj.get_node("death_ray_sprite").animation = "aim"
		death_ray_obj.set_collision_mask_bit(3, false)
	if stage == 3:
		death_ray_obj.free()
		death_ray_obj = null
		
func fire_shotgun():
	var spread = deg2rad(22)
	var shot_count = 10
	for i in range(shot_count):
		var rotation_offset = rand_range(-spread/2, +spread/2)
		var shot = shotgun_scene.instance()
		shot.global_position = self.global_position
		shot.global_rotation = self.global_rotation + rotation_offset
		get_node("/root/root").add_child(shot)
		var snd = get_node("/root/root/snd_shotgun")
		if not snd.playing:
			snd.play()
		
func fire_rocket():
	var shot = rocket_scene.instance()
	shot.global_position = self.global_position
	shot.global_rotation = self.global_rotation
	get_node("/root/root").add_child(shot)
	var snd = get_node("/root/root/snd_rocket")
	if not snd.playing:
		snd.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var player = get_node("/root/root/player_ship")

	if not player.hidden:
		var target_rotation = player.global_position.angle_to_point(self.global_position)
		
		var delta_angle = self.global_rotation - target_rotation
		if abs(delta_angle) < angular_speed:
			self.global_rotation = target_rotation
		else:
			if Globals.norm_angle_rad(delta_angle) > deg2rad(180):
				self.global_rotation += angular_speed
			else:
				self.global_rotation -= angular_speed
	
	if Globals.state == Globals.STATE_FIGHT:
		counter += 1
		if counter >= shot_delay_list[shot_stage]:
			if type == Globals.DEATH_RAY:
				fire_death_ray(shot_stage)
			elif type == Globals.SHOTGUN:
				fire_shotgun()
			elif type == Globals.LASER:
				fire_laser()
			elif type == Globals.ROCKET:
				fire_rocket()
			else:
				pass
			
			counter = 0
			shot_stage = (shot_stage + 1) % len(shot_delay_list)

