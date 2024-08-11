extends Area2D

func _process(_delta):
	position.y +=0.5
	$Anim.play("ataque")

func _on_body_entered(body):
	if body.is_in_group("enemie"):
		body.hit()
		queue_free()
	
