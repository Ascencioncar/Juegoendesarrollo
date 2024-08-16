extends CharacterBody2D

enum State { IDLE, WALK, HIDE, ESCO }

var velocidad : int = 200
var dash_speed: int = 500
var dashing:bool= false
var can_dash:bool=true
var salto : int = 250
var gravedad : int = 400
var estado_actual : State = State.IDLE
var escoger: bool = true
var tiene_escopeta: bool = false  # Nueva variable para rastrear si el jugador tiene la escopeta
var cont_jump:int=0
var max_jump:int=2

@export var balazoderecha: PackedScene
@export var balazoizquierda: PackedScene
@export var saltodoble: PackedScene
@export var particulas_escopeta: PackedScene


@onready var anim = $AnimatedSprite2D
var escopeta = null  # Referencia a la escopeta detectada

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
	if tiene_escopeta:
		return  # Si el jugador tiene la escopeta, no permite volver a IDLE o WALK

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
		$CollisionShape2D.scale.y = 1.0
		$CollisionShape2D.scale.x = 1.0
		$CollisionShape2D.position.y = 1

func _input(_event):
	if Input.is_action_just_pressed("agachar") and estado_actual != State.HIDE:
		entrar_en_estado_oculto()
		$CollisionShape2D.scale.y = 0.5
		$CollisionShape2D.scale.x = 0.5
		$CollisionShape2D.position.y = 6.5
		
	if Input.is_action_just_pressed("interactuar") and estado_actual != State.HIDE and escopeta:
		if escopeta:  # Verifica si la referencia a la escopeta es válida antes de interactuar
			cogerescopeta()
			
	if Input.is_action_just_pressed("dash"):
		dashing= true
		$dash_timer.start()
		
func entrar_en_estado_oculto():
	estado_actual = State.HIDE
	set_physics_process(false)
	anim.play("hide")
	await anim.animation_finished
	set_physics_process(true)
	
func salir_del_estado_oculto():
	if tiene_escopeta:
		estado_actual = State.ESCO  # Si tiene escopeta, solo puede volver a ESCO
		anim.play("escopeta_idle")
	else:
		estado_actual = State.IDLE
		anim.play("idle")

func cogerescopeta():
	if escopeta:
		$"../CanvasLayer/TextureProgressBar".visible=true
		escopeta.recogida()  # Llama al método de la escopeta para eliminarla
		escopeta = null  # Libera la referencia a la escopeta después de recogerla
		estado_actual = State.ESCO
		anim.play("escopeta_idle")
		escoger = true  # Resetea la variable para no recoger múltiples veces
		tiene_escopeta = true  # Marca que el jugador ahora tiene la escopeta

func movimiento_escopeta():
	if Input.is_action_pressed("ui_right"):
			anim.play("walk+escopeta")
			velocity.x = velocidad
			anim.flip_h = false
			estado_actual = State.ESCO
			if dashing==true:
				velocity.x = dash_speed
					
	elif Input.is_action_pressed("ui_left"):
			anim.play("walk+escopeta")
			velocity.x = -velocidad
			anim.flip_h = true
			estado_actual = State.ESCO
			if dashing==true:
				velocity.x = -dash_speed
					
	else:
		velocity.x = 0
		anim.play("escopeta_idle")
			
	if is_on_floor():
		cont_jump=0
		if Input.is_action_just_pressed("saltar"):
			set_physics_process(false)
			anim.play("salto_escopeta")
			await anim.animation_finished
			cont_jump+=1
			velocity.y= -salto
			dobleSalto()
			get_tree().get_nodes_in_group("balasplayer")[0].Disminuirbala(1)
			set_physics_process(true)
			
	else: 
		if Input.is_action_just_pressed("saltar") and max_jump > cont_jump:
				cont_jump+=1
				set_physics_process(false)
				anim.play("salto_escopeta")
				await anim.animation_finished
				velocity.y = -salto
				dobleSalto()
				get_tree().get_nodes_in_group("balasplayer")[0].Disminuirbala(1)
				set_physics_process(true)	
				
	if Input.is_action_just_pressed("atacar"):
		set_physics_process(false)
		if anim.flip_h == true:
			anim.play("atack_escopeta")
			
			await anim.animation_finished
			proyectilizquierda()
			set_physics_process(true)
			get_tree().get_nodes_in_group("balasplayer")[0].Disminuirbala(1)
			
		else:
			set_physics_process(false)
			anim.play("atack_escopeta")
		
			await anim.animation_finished
			proyectilderecha()
			set_physics_process(true)
			get_tree().get_nodes_in_group("balasplayer")[0].Disminuirbala(1)
			
func _on_detencion_area_entered(area):
	if area.is_in_group("escopeta"):
		escopeta = area  # Guarda la referencia de la escopeta detectada
		escoger = false
		print("Escopeta encontrada")

func _on_detencion_area_exited(area):
	if area.is_in_group("escopeta"):
		escopeta = null  # Elimina la referencia cuando el jugador sale del área
		escoger = true

func proyectilderecha():
		var newproyectil = balazoderecha.instantiate()
		newproyectil.global_position = $"proyectiles/direccionDerecha".global_position
		get_parent().add_child(newproyectil)
		
func proyectilizquierda():
	var newproyectil = balazoizquierda.instantiate()
	newproyectil.global_position = $"proyectiles/direccionizquierda".global_position
	get_parent().add_child(newproyectil)
	
func dobleSalto():
	var newproyectil1 = saltodoble.instantiate()
	var newproyectil2 = saltodoble.instantiate()
	newproyectil1.global_position = $dobleSalto/salto1.global_position
	get_parent().add_child(newproyectil1)
	newproyectil2.global_position = $dobleSalto/salto2.global_position
	get_parent().add_child(newproyectil2)

func _on_dash_timer_timeout():
	dashing=false
	
func recargarbalas():
	set_physics_process(false)
	anim.play("recarga_escopeta")
	await anim.animation_finished
	set_physics_process(true)

func particulas():
	var instance = particulas_escopeta.instantiate()
	add_sibling(instance)
	
	instance.global_position = global_position + Vector2(0,5)
	
