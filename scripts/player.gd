extends CharacterBody2D

var max_speed: int = 420
var gravity: float = 10.0
var jump_force: int = 280
var acceleration: float = 2.5
var slope_acceleration: float = 2.0
var slope_deceleration: float = 10.0
var jump_buffer_time: int = 5
var coyote_time: int = 6
var fall_time: int = 1000

@onready var sprite = $Sprite
@onready var collision_normal = $"Collision (Normal)"
@onready var collision_jump = $"Collision (Jump)"
@onready var raycast = $RayCast
@onready var raycast2 = $RayCast2
@onready var raycast3 = $RayCast3
@onready var camera = $Camera
@onready var fps = $"../../../../HUD SubViewportContainer/HUD SubViewport/HUD/CanvasLayer/FPS"
@onready var variables_left = $"../../../../HUD SubViewportContainer/HUD SubViewport/HUD/CanvasLayer/Variables (Left)"
@onready var variables_right = $"../../../../HUD SubViewportContainer/HUD SubViewport/HUD/CanvasLayer/Variables (Right)"

var jump_buffer_counter: int = 0
var coyote_time_counter: int = 0
var fall_time_counter: int = 0
var last_run_anim: String
var horizontal_direction: float
var resistance: float
var normal: Vector2
var offset: float
var floor_angle: int


func _physics_process(_delta):
	move_and_slide()


# Respawn after falling in a bottomless pit
	if position.y > 1000:
		respawn()


# Jumping
	if is_on_floor():
		coyote_time_counter = coyote_time
		fall_time_counter = fall_time
	else:
		if coyote_time_counter > 0:
			coyote_time_counter -= 1
		if fall_time_counter > 0:
			fall_time_counter -= 1
		velocity.y += gravity
		if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
			velocity.x += normal.x * 600
		else:
			velocity.x += normal.x * 300

	if Input.is_action_just_pressed("jump"):
		jump_buffer_counter = jump_buffer_time

	if jump_buffer_counter > 0:
		jump_buffer_counter -= 1

	if jump_buffer_counter > 0 and coyote_time_counter > 0:
		velocity.y = -jump_force
		jump_buffer_counter = 0
		coyote_time_counter = 0
		fall_time_counter = 0

	if Input.is_action_just_released("jump"):
		if velocity.y < 0:
			velocity.y += 60

	velocity.y = clamp(velocity.y, -1000, 1000)


# Horizontal movement
	horizontal_direction = Input.get_axis("move_left","move_right")

	if Input.is_action_pressed("move_right") and !Input.is_action_pressed("move_left"):
		if !is_on_floor():
			sprite.flip_h = false
		if velocity.x > -1:
			velocity.x += acceleration * abs(horizontal_direction)
			resistance = 0.02
			sprite.flip_h = false
		else:
			resistance = 0.06
			velocity.x = lerp(velocity.x,0.0,resistance)
	elif Input.is_action_pressed("move_left") and !Input.is_action_pressed("move_right"):
		if !is_on_floor():
			sprite.flip_h = true
		if velocity.x < 1:
			velocity.x -= acceleration * abs(horizontal_direction)
			resistance = 0.02
			sprite.flip_h = true
		else:
			resistance = 0.06
			velocity.x = lerp(velocity.x,0.0,resistance)
	else:
		resistance = 0.02
		velocity.x = lerp(velocity.x,0.0,resistance)


# Acceleration and deceleration on slopes
	#if horizontal_direction != 0:
		#if (horizontal_direction < 0.0 and normal.x > 0.0) or (horizontal_direction > 0.0 and normal.x < 0.0):
			#acceleration = 2.5 / (slope_deceleration + sin(floor_angle))
			#if int(velocity.x) == max_speed:
				#velocity.x -= (slope_deceleration + sin(floor_angle))
			#elif int(velocity.x) == -max_speed:
				#velocity.x += (slope_acceleration + sin(floor_angle))
		#elif (horizontal_direction < 0.0 and normal.x < 0.0) or (horizontal_direction > 0.0 and normal.x > 0.0):
			#acceleration = 2.5 * (slope_acceleration + sin(floor_angle))
		#else:
			#acceleration = 2.5


# Turning around
	if int(velocity.x) == 0:
		resistance = 0.02
	if velocity.x < 100 and velocity.x > 0:
		if horizontal_direction < 0.0:
			velocity.x = lerp(velocity.x,0.0,resistance * 15)
	if velocity.x > -100 and velocity.x < 0:
		if horizontal_direction > 0.0:
			velocity.x = lerp(velocity.x,0.0,resistance * 15)
	if velocity.x < 3 and velocity.x > 0:
		if horizontal_direction == 0.0:
			velocity.x = lerp(velocity.x,0.0,resistance * 15)
	if velocity.x > -3 and velocity.x < 0:
		if horizontal_direction == 0.0:
			velocity.x = lerp(velocity.x,0.0,resistance * 15)

	velocity.x = clamp(velocity.x, -max_speed, max_speed)


# Rotation
	normal = get_floor_normal()
	offset = deg_to_rad(90)
	floor_angle = int(abs(rad_to_deg(normal.angle())))

	if is_on_floor() and raycast.is_colliding() and raycast2.is_colliding():
		if snapped(normal.angle(),0.1) != 0.0 and int(normal.angle()) != 3:
			if sprite.animation != "Idle":
				sprite.rotation = normal.angle() + offset
			else:
				sprite.rotation = 0
			raycast.rotation = normal.angle() + offset
			raycast2.rotation = normal.angle() + offset
			raycast3.rotation = normal.angle() + offset
	else:
		sprite.rotation = lerp(sprite.rotation,0.0,0.2)
		raycast.rotation = lerp(raycast.rotation,0.0,0.2)
		raycast2.rotation = lerp(raycast2.rotation,0.0,0.2)
		raycast3.rotation = lerp(raycast3.rotation,0.0,0.2)


# Change RayCast position on slopes
	if floor_angle > 90 and floor_angle < 130:
		raycast.position.y = -13
		raycast2.position.y = -19
		raycast.position.x = -10
		raycast2.position.x = 10
	elif floor_angle > 130 and floor_angle < 180:
		raycast.position.y = -7
		raycast2.position.y = -22
		raycast.position.x = -5
		raycast2.position.x = 8
	elif floor_angle < 90 and floor_angle > 50:
		raycast.position.y = -19
		raycast2.position.y = -13
		raycast.position.x = -10
		raycast2.position.x = 10
	elif floor_angle < 50 and floor_angle > 0:
		raycast.position.y = -22
		raycast2.position.y = -7
		raycast.position.x = -8
		raycast2.position.x = 5
	else:
		raycast.position.y = -16
		raycast2.position.y = -16
		raycast.position.x = -10
		raycast2.position.x = 10


# Change collision shape
	if raycast.is_colliding() and velocity.y >= 0 or raycast2.is_colliding() and velocity.y >= 0:
		collision_normal.disabled = false
		collision_jump.disabled = true
	else:
		collision_normal.disabled = true
		collision_jump.disabled = false


# Update animations
	if is_on_floor():
		if resistance == 0.02:
			if int(velocity.x) == 0:
				sprite.play("Idle")
			elif int(velocity.x) != 0:
				if abs(velocity.x) > 0 and abs(velocity.x) < 80:
					sprite.play("Walk1")
					last_run_anim = "Walk1"
				elif abs(velocity.x) > 80 and abs(velocity.x) < 185:
					sprite.play("Walk2", abs(velocity.x) * 0.0075)
					last_run_anim = "Walk2"
				elif abs(velocity.x) > 185 and abs(velocity.x) < 310:
					sprite.play("Run1", abs(velocity.x) * 0.004)
					last_run_anim = "Run1"
				elif abs(velocity.x) >= 310:
					sprite.play("Run2", abs(velocity.x) * 0.0028)
					last_run_anim = "Run2"
		elif abs(velocity.x) > 140:
			if last_run_anim != "Walk1" and last_run_anim != "Walk2":
				sprite.play("Skid")
		elif abs(velocity.x) < 140:
			if horizontal_direction != 0:
				if last_run_anim == "Walk1" or last_run_anim == "Walk2":
					sprite.play("Turn (Slow)")
				else:
					sprite.play("Turn (Fast)")
		if is_on_floor():
			collision_normal.disabled = false
			collision_jump.disabled = true
	if (Input.is_action_pressed("jump") and velocity.y < 0) or (Input.is_action_just_released("jump") and velocity.y < 0):
		if velocity.y > -250:
			sprite.play("Jump")
		else:
			sprite.play("Jump (Start)")
	if not is_on_floor():
		if sprite.animation != "Fall" and sprite.animation != "Fall (Loop)":
			if raycast3.is_colliding() and velocity.y > 0 and fall_time_counter == 0:
				sprite.play("Fall")
		if sprite.animation == "Fall" and not raycast3.is_colliding():
			sprite.play("Fall (Loop)")


# Resize RayCast3 depending on vertical velocity
	if velocity.y > 0.0:
		raycast3.target_position.y = 55 + velocity.y * 0.1
	else:
		raycast3.target_position.y = 55


func respawn():
	position.x = 86
	position.y = 119
	velocity.x = 0
	velocity.y = 0
