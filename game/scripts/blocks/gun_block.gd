extends Area2D

class_name GunBlock

var health = Globals.MAX_BLOCK_HEALTH

# node format: x, y, angle
var out_nodes = [
]

var in_node = [3, 7, 180]

func setup(type):
	get_node("gun_sprite").setup(type)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
