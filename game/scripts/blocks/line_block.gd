extends Area2D

class_name LineBlock

var health = Globals.MAX_BLOCK_HEALTH

# node format: x, y, angle
var out_nodes = [
	[24, 3, 45],
]

var in_node = [3, 3, 180]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
