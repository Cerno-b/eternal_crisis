extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const SPEED = 6

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("shots")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.position += Vector2(1,0).rotated(self.rotation) * SPEED
	var outside = false
	outside = outside || self.position.x < -100
	outside = outside || self.position.y < -100
	outside = outside || self.global_position.x > get_viewport().size.x + 100
	outside = outside || self.global_position.y > get_viewport().size.y + 100
	
	
	
	if outside:
		self.free()


func _on_shot_body_entered(body):
	get_parent().handle_hit(self, body)
