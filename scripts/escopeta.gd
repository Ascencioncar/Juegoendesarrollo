extends Area2D

@onready var label = $Label

func _ready():
	label.visible = false  

func _on_body_entered(body):
	if body.is_in_group("player"):
		label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		label.visible = false
		
func recogida():
	queue_free()


