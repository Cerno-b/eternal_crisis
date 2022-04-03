extends CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready():
	self.position.x = -get_parent().in_node[0] + 22
	self.position.y = -get_parent().in_node[1] + 22


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
