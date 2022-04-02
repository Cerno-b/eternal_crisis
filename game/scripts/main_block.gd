extends AnimatedSprite

var health = 100

# node format: x, y, angle
var out_nodes = [
	[41, 22, 0],
	[22, 41, 90],
	[3, 22, 180],
	[22, 3, 270]
]

var in_node = [21, 21, 0]

# Called when the node enters the scene tree for the first time.
func _ready():
	self.offset.x = -in_node[0]
	self.offset.y = -in_node[1]
	
	for out_node in out_nodes:
		out_node[0] -= in_node[0]
		out_node[1] -= in_node[1]
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
