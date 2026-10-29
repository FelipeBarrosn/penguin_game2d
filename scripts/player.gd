extends CharacterBody2D

enum PlayerState {
	idle,
	walk,
	jump,
	fall,
	crouch
}

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var player_collision: CollisionShape2D = $PlayerCollision

const SPEED = 100.0
const JUMP_VELOCITY = -300.0

var jump_count = 0
@export var max_jump_count = 2
var status: PlayerState
var direction = 0

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match status:
		PlayerState.idle:
			idle_state()
		PlayerState.walk:
			walk_state()
		PlayerState.jump:
			jump_state()
		PlayerState.fall:
			fall_state()
		PlayerState.crouch:
			crouch_state()
	
	move_and_slide()

func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")

func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func go_to_fall_state():
	status = PlayerState.fall
	anim.play("fall") 

func go_to_crouch_state():
	status = PlayerState.crouch
	anim.play("crouch")
	player_collision.shape.radius = 5
	player_collision.shape.height = 10
	player_collision.position.y = 3

func exit_from_crouch_state():
	player_collision.shape.radius = 6
	player_collision.shape.height = 16
	player_collision.position.y = 0


func idle_state():
	move()
	if Input.is_action_just_pressed("Jump"):
		go_to_jump_state()
		return
		
	if velocity.x != 0:
		go_to_walk_state()
		return
		
	if Input.is_action_pressed("Crouch"):
		go_to_crouch_state()
		return

func walk_state():
	move()
	if velocity.x == 0:
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("Jump"):
		go_to_jump_state()
		return
		
	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()
		return

func jump_state():
	move()
	if Input.is_action_just_pressed("Jump") && can_jump():
		go_to_jump_state()
		return
	
	if velocity.y > 0:
		go_to_fall_state()
		return

func fall_state():
	move()
	
	if Input.is_action_just_pressed("Jump") && can_jump():
		go_to_jump_state()
		return
	
	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
			return

func crouch_state():
	update_direction()
	if Input.is_action_just_released("Crouch"):
		exit_from_crouch_state();
		go_to_idle_state()
		return

func move():
	update_direction()
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		


func update_direction():
	direction = Input.get_axis("Left", "Right")
	
	if direction < 0:
		anim.flip_h = true
	elif direction > 0:
		anim.flip_h = false

func can_jump() -> bool:
	return jump_count < max_jump_count
