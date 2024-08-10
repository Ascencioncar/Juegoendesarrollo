extends CharacterBody2D

enum State { IDLE, WALK, HIDE, ESCO}

var velocidad : int = 200
var salto : int = 250
var gravedad : int = 400
var estado_actual : State = State.IDLE
var escoger:bool=false

@onready var anim = $AnimatedSprite2D

func _ready():
	set_process(true)
	set_physics_process(true)

func _physics_process(delta):
	velocity.y += gravedad * delta

	match estado_actual:
		State.IDLE, State.WALK:
			controlar_movimiento()
		State.HIDE:
			controlar_movimiento_oculto()
		State.ESCO:
			movimiento_escopeta()

	move_and_slide()

func controlar_movimiento():
	if Input.is_action_pressed("ui_right"):
		velocity.x = velocidad
		anim.flip_h = false
		estado_actual = State.WALK
		anim.play("walk")
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -velocidad
		anim.flip_h = true
		estado_actual = State.WALK
		anim.play("walk")
	else:
		velocity.x = 0
		estado_actual = State.IDLE
		anim.play("idle")

	if is_on_floor() and Input.is_action_just_pressed("saltar"):
		velocity.y = -salto

func controlar_movimiento_oculto():
	if Input.is_action_pressed("ui_right"):
		velocity.x = velocidad
		anim.flip_h = false
		anim.play("hide_walk")
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -velocidad
		anim.flip_h = true
		anim.play("hide_walk")
	else:
		velocity.x = 0
		anim.play("hide_idle")

	if is_on_floor() and Input.is_action_just_pressed("saltar"):
		velocity.y = -salto
		salir_del_estado_oculto()
		$CollisionShape2D.scale.y=1.0
		$CollisionShape2D.scale.x=1.0
		$CollisionShape2D.position.y=1

func _input(_event):
	if Input.is_action_just_pressed("agachar") and estado_actual != State.HIDE:
		entrar_en_estado_oculto()
		$CollisionShape2D.scale.y=0.5
		$CollisionShape2D.scale.x=0.5
		$CollisionShape2D.position.y=6.5
		
	if Input.is_action_just_pressed("interactuar") and estado_actual != State.HIDE and !escoger:
		cogerescopeta()
		
func entrar_en_estado_oculto():
	estado_actual = State.HIDE
	anim.play("hide")
	
func salir_del_estado_oculto():
	estado_actual = State.IDLE
	anim.play("idle")

func cogerescopeta():
	estado_actual = State.ESCO
	anim.play("escopeta_idle")
	
func movimiento_escopeta():
	if Input.is_action_pressed("ui_right"):
		velocity.x = velocidad
		anim.flip_h = false
		estado_actual = State.ESCO
		anim.play("escopeta_idle")
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -velocidad
		anim.flip_h = true
		estado_actual = State.ESCO
		anim.play("escopeta_idle")
	else:
		velocity.x = 0
		estado_actual = State.ESCO
		anim.play("escopeta_idle")


func _on_detencion_area_entered(area):
	if area.is_in_group("escopeta"):
		escoger = true
		print("Escopeta encontrada")
