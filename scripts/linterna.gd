extends Area2D



func _on_body_entered(body):
	if body.is_in_group("player"):
		print("linterna")
		$Label.visible=true
		#queue_free()
	elif body.is_in_group(""):
		print("linterna no")
		$Label.visible=false
