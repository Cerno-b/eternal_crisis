extends Node

# max block health
const MAX_BLOCK_HEALTH = 20
const MAX_MAIN_BLOCK_HEALTH = 40

enum {
	DEATH_RAY,
	LASER,
	ROCKET,
	SHOTGUN,
	SHOT_COUNT
}

enum {STATE_INIT_BEGIN, STATE_INIT, STATE_FIGHT, STATE_PLAYER_HIT, STATE_BOSS_DEFEATED}

var state = STATE_INIT_BEGIN

var state_counter = 0

const STATE_MAX_WAIT = {
	STATE_INIT_BEGIN: 0,
	STATE_INIT: 200,
	STATE_FIGHT: 0,
	STATE_PLAYER_HIT: 100,
	STATE_BOSS_DEFEATED: 200
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
func _process(delta):
	var max_wait = STATE_MAX_WAIT[state]
	if state in [STATE_INIT, STATE_BOSS_DEFEATED, STATE_PLAYER_HIT]:
		state_counter += 1
	if max_wait > 0 and state_counter >= max_wait:
		state_counter = 0
		if state == STATE_INIT:
			state = STATE_FIGHT
		elif state == STATE_BOSS_DEFEATED:
			state = STATE_INIT_BEGIN
		elif state == STATE_PLAYER_HIT:
			state = STATE_FIGHT
