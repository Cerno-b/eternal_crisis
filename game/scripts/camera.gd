extends Camera2D

export var decay = 0.8
export var max_offset = Vector2(100, 75)

var trauma = 0
var trauma_power = 2

export var target: NodePath

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	var border = 20
	self.limit_left = -border
	self.limit_top = -border
	self.limit_right = get_viewport().size.x + border
	self.limit_bottom = get_viewport().size.y + border

func shake():
	var amount = pow(trauma, trauma_power)
	offset.x = max_offset.x * amount * rand_range(-1, 1)
	offset.y = max_offset.y * amount * rand_range(-1, 1)

func _process(delta):
	# self.global_position = get_node(target).global_position
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func start_shake():
	trauma = 0.3

func _on_root_block_destroyed():
	start_shake()
