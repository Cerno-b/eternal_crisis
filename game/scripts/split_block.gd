extends AnimatedSprite

var health = 100

# node format: x, y, angle
var out_nodes = [
	[11, 3, -45],
	[11, 21, 45],
]

var in_node = [3, 12, 180]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.offset.x = -in_node[0]
	self.offset.y = -in_node[1]

	for out_node in out_nodes:
		out_node[0] -= in_node[0]
		out_node[1] -= in_node[1]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#if Input.is_action_pressed("ui_accept"):
	#	self.rotation_degrees += 5
