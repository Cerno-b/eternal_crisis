extends Area2D

class_name Shotgun

const SPEED = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	self.position += Vector2(1,0).rotated(self.rotation) * SPEED
	var outside = false
	outside = outside || self.position.x < -100
	outside = outside || self.position.y < -100
	outside = outside || self.global_position.x > get_viewport().size.x + 100
	outside = outside || self.global_position.y > get_viewport().size.y + 100
	
	if outside:
		self.queue_free()
