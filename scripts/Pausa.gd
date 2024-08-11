extends CanvasLayer


func _physics_process(_delta):
	if Input.is_action_just_pressed("pausa"):
		get_tree().paused= not get_tree().paused
		$ColorRect.visible= not $ColorRect
