extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.high_score = max(Globals.high_score, Globals.score)
	text = "SCORE: " + str(Globals.score) + "\n\n"
	text += "SESSION HIGH SCORE: " + str(Globals.high_score) + "\n\n"
	text += "YOU REACHED ROUND " + str(Globals.level) + "\n\n"
	set_text(text)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
