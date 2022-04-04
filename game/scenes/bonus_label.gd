extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var visible_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		visible_timer -= 1
	else:
		visible_timer = 80
	if visible_timer <= 0:
		visible = false