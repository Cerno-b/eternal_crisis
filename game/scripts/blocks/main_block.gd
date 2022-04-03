extends Area2D

class_name MainBlock

var health = Globals.MAX_MAIN_BLOCK_HEALTH

# node format: x, y, angle
var out_nodes = [
	[41, 22, 0],
	[22, 41, 90],
	[3, 22, 180],
	[22, 3, 270]
]

var target = 320
var max_distance = 50

var in_node = [21, 21, 0]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
#	pass
	
