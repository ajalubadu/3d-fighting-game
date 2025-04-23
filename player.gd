class_name Player
extends CharacterBody3D

@onready var camera_rotation_center: Node3D = $CameraRotationCenter
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var camera_3d: Camera3D = $CameraRotationCenter/Camera3D

@export var enemy : StaticBody3D

var gravity_strength : float = 20
var jump_strength : float = 5
var mouse_sensetivity : float = 0.002
var movement_speed : float = 5
var rotation_speed : float = 10
var punch_damage : int = 10

@export var health : int = 100


func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())


func _ready() -> void:
	if is_multiplayer_authority():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		camera_3d.current = true


func _process(delta: float) -> void:
	#var top_down_position_difference = Vector2(enemy.position.x, enemy.position.z) - Vector2(position.x, position.z)
	#var angle = atan2(top_down_position_difference.x, top_down_position_difference.y)
	##rotation.y = rotate_toward(rotation.y, angle, delta * rotation_speed * abs(angle_difference(rotation.y, angle)))
	#rotation.y = angle
	if is_multiplayer_authority():
		animation_tree.set("parameters/conditions/punching", Input.is_action_just_pressed("LMB"))


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity.y += -1 * gravity_strength * delta
		
		var input_x = Input.get_axis("move_left", "move_right")
		var input_z = Input.get_axis("move_backwards", "move_forwards")
		
		velocity = (transform.basis * Vector3(-1 * input_x, 0,input_z).normalized() * movement_speed) + velocity * Vector3(0,1,0)
		
		if is_on_floor() and Input.is_action_pressed("jump"):
			velocity.y = jump_strength
		
		move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event is InputEventMouseMotion:
			handle_rotation(event)


func handle_rotation(event: InputEventMouseMotion):
	rotate_y(-1 * event.relative.x * mouse_sensetivity)
	camera_rotation_center.rotate_x(event.relative.y * mouse_sensetivity)
	
	camera_rotation_center.rotation.x = deg_to_rad(clamp(rad_to_deg(camera_rotation_center.rotation.x), -90, 90))


func damage(amount: int) -> void:
	print(name, "damaged")
	if health - amount <= 0:
		pass
	else:
		print(health, "  ", amount)
		
		health -= amount
		
		print(health)


func _on_area_3d_body_entered(body: Node3D) -> void:
	print(name, "entered")
	if body is Player and not body == self:
		print(name, "hit")
		body.damage.rpc(punch_damage)
