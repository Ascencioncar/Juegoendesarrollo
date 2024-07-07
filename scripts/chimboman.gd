extends CharacterBody2D

var velocidad : int = 200
var salto : int = 250
var gravedad : int = 400
var hitplayer:bool = false
var cont_jump : int = 0
var max_jump : int = 2

@onready var anim = $anim
@onready var collisionplayer = $Collisionplayer

# Ruta al nuevo personaje que reemplazará al actual
var new_character_path = "res://scenes/chimboman2.tscn"

func _physics_process(delta):
	velocity.y += gravedad * delta
	if !hitplayer:
		if Input.is_action_pressed("ui_right"):
			velocity.x = velocidad
			anim.flip_h = false
		elif Input.is_action_pressed("ui_left"):
			velocity.x = -velocidad
			anim.flip_h = true
		else:
			velocity.x = 0

		if is_on_floor():
			cont_jump = 0
			if Input.is_action_just_pressed("saltar"):
				velocity.y = -salto

		animaciones()

	move_and_slide()

func animaciones():
	if is_on_floor():
		if velocity.x != 0:
			anim.play("walk")
		else:
			anim.play("idle")

func _input(_event):
	if Input.is_action_just_pressed("agachar") and !hitplayer:
		set_physics_process(false)
		anim.play("hide")
		await anim.animation_finished	   
		replace_character()

func replace_character():
	# Cargar la nueva escena del personaje
	var new_character_scene = load(new_character_path)
	var new_character = new_character_scene.instantiate()

	# Obtener el nodo padre del personaje actual
	var parent = get_parent()

	# Transferir las propiedades físicas y posición
	new_character.velocity = self.velocity
	new_character.global_position = self.global_position

	# Agregar el nuevo personaje al nodo padre
	parent.add_child(new_character)

	# Remover el personaje actual de la escena
	queue_free()



