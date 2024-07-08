extends CharacterBody2D

var velocidad : int = 200
var salto : int = 250
var gravedad : int = 400
var hitplayer:bool = false
var iluminar:bool=false

@onready var anim = $Anim2
@onready var collisionplayer = $Collisionplayer2

# Ruta al nuevo personaje que reemplazará al actual
var new_character_path = "res://scenes/chimboman.tscn"

func _ready():
	$PointLight2D.visible=false
	iluminar=false
	
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


		animaciones()

	move_and_slide()

func animaciones():
	if is_on_floor():
		if velocity.x != 0:
			anim.play("mueve + hide")
		else:
			anim.play("idlehide")

func _input(_event):
	if Input.is_action_just_pressed("agachar") and !hitplayer:
		set_physics_process(false)
		anim.play("up")
		$linterna.play()
		await anim.animation_finished
		replace_character()
		
	if Input.is_action_just_pressed("alumbrar") and !hitplayer:
		$PointLight2D.visible=true
		$linterna.play()

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

	# Reactivar el proceso físico del nuevo personaje
	new_character.set_physics_process(true)

