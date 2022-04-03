extends Node

# max block health
const MAX_BLOCK_HEALTH = 20
const MAX_MAIN_BLOCK_HEALTH = 40

enum {
	DEATH_RAY,
	LASER,
	ROCKET,
	SHOTGUN
}

# damage multiplier for attacking a "deeper" block
const GROUP_BONUS_DAMAGE_MULTIPLIER = 1.1

func norm_angle_degree(angle_deg):
	while angle_deg < 0:
		angle_deg += 360
	while angle_deg >= 360:
		angle_deg -= 360
	return angle_deg
	
func norm_angle_rad(angle_rad):
	while angle_rad < 0:
		angle_rad += 2*PI
	while angle_rad >= 2*PI:
		angle_rad -= 2*PI
	return angle_rad
		

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
