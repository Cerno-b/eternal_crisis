extends AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	self.offset.x = -get_parent().in_node[0]
	self.offset.y = -get_parent().in_node[1]

	for out_node in get_parent().out_nodes:
		out_node[0] -= get_parent().in_node[0]
		out_node[1] -= get_parent().in_node[1]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	#if Input.is_action_pressed("ui_accept"):
	#	self.rotation_degrees += 5
