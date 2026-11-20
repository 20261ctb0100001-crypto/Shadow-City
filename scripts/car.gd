extends CharacterBody3D

@export var acceleration: float = 12.0
@export var max_speed: float = 17.0
@export var reverse_speed: float = 7.0
@export var steering_speed: float = 1.55

var current_speed: float = 0.0
var driver: CharacterBody3D = null
var vehicle_camera: Camera3D
var just_entered: bool = false

func _ready() -> void:
	add_to_group("vehicles")
	_build_vehicle()
	_build_camera()

func _build_vehicle() -> void:
	_add_part("Car body", Vector3(0, 0.72, 0), Vector3(2.0, 0.75, 4.0), Color(0.56, 0.12, 0.10))
	_add_part("Cabin", Vector3(0, 1.32, -0.25), Vector3(1.55, 0.72, 1.9), Color(0.10, 0.18, 0.23))
	_add_part("Front glass", Vector3(0, 1.36, -1.22), Vector3(1.35, 0.52, 0.08), Color(0.16, 0.30, 0.38))
	_add_part("Rear glass", Vector3(0, 1.36, 0.72), Vector3(1.35, 0.52, 0.08), Color(0.16, 0.30, 0.38))

	# Detalhes externos para deixar o primeiro carro menos parecido com um bloco.
	_add_part("Front bumper", Vector3(0, 0.42, -2.02), Vector3(1.92, 0.22, 0.16), Color(0.10, 0.11, 0.12))
	_add_part("Rear bumper", Vector3(0, 0.42, 2.02), Vector3(1.92, 0.22, 0.16), Color(0.10, 0.11, 0.12))
	_add_part("Front grille", Vector3(0, 0.69, -2.035), Vector3(0.72, 0.22, 0.035), Color(0.025, 0.03, 0.035))
	_add_part("Front lower grille", Vector3(0, 0.48, -2.04), Vector3(1.0, 0.07, 0.035), Color(0.035, 0.04, 0.045))
	_add_part("Left headlight", Vector3(-0.70, 0.83, -2.035), Vector3(0.42, 0.20, 0.055), Color(0.92, 0.88, 0.68))
	_add_part("Right headlight", Vector3(0.70, 0.83, -2.035), Vector3(0.42, 0.20, 0.055), Color(0.92, 0.88, 0.68))
	_add_part("Left tail light", Vector3(-0.70, 0.82, 2.035), Vector3(0.42, 0.22, 0.055), Color(0.72, 0.045, 0.025))
	_add_part("Right tail light", Vector3(0.70, 0.82, 2.035), Vector3(0.42, 0.22, 0.055), Color(0.72, 0.045, 0.025))
	_add_part("Left mirror", Vector3(-0.91, 1.35, -0.93), Vector3(0.22, 0.16, 0.28), Color(0.12, 0.13, 0.14))
	_add_part("Right mirror", Vector3(0.91, 1.35, -0.93), Vector3(0.22, 0.16, 0.28), Color(0.12, 0.13, 0.14))
	_add_part("Left side window front", Vector3(-0.79, 1.38, -0.55), Vector3(0.045, 0.46, 0.90), Color(0.10, 0.19, 0.24))
	_add_part("Right side window front", Vector3(0.79, 1.38, -0.55), Vector3(0.045, 0.46, 0.90), Color(0.10, 0.19, 0.24))
	_add_part("Left side window rear", Vector3(-0.79, 1.38, 0.48), Vector3(0.045, 0.46, 0.70), Color(0.10, 0.19, 0.24))
	_add_part("Right side window rear", Vector3(0.79, 1.38, 0.48), Vector3(0.045, 0.46, 0.70), Color(0.10, 0.19, 0.24))
	_add_part("Left door handle", Vector3(-1.015, 0.98, -0.05), Vector3(0.035, 0.055, 0.28), Color(0.72, 0.72, 0.68))
	_add_part("Right door handle", Vector3(1.015, 0.98, -0.05), Vector3(0.035, 0.055, 0.28), Color(0.72, 0.72, 0.68))
	_add_part("Left rocker panel", Vector3(-0.92, 0.39, 0), Vector3(0.10, 0.16, 2.1), Color(0.12, 0.12, 0.13))
	_add_part("Right rocker panel", Vector3(0.92, 0.39, 0), Vector3(0.10, 0.16, 2.1), Color(0.12, 0.12, 0.13))

	for side in [-1.0, 1.0]:
		for axle in [-1.25, 1.25]:
			var wheel := MeshInstance3D.new()
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.38
			wheel_mesh.bottom_radius = 0.38
			wheel_mesh.height = 0.22
			wheel.mesh = wheel_mesh
			wheel.rotation_degrees.z = 90
			wheel.position = Vector3(side * 1.02, 0.38, axle)
			var wheel_material := StandardMaterial3D.new()
			wheel_material.albedo_color = Color(0.035, 0.04, 0.045)
			wheel.material_override = wheel_material
			add_child(wheel)
			var rim := MeshInstance3D.new()
			var rim_mesh := CylinderMesh.new()
			rim_mesh.top_radius = 0.19
			rim_mesh.bottom_radius = 0.19
			rim_mesh.height = 0.235
			rim.mesh = rim_mesh
			rim.rotation_degrees.z = 90
			rim.position = Vector3(side * 1.14, 0.38, axle)
			var rim_material := StandardMaterial3D.new()
			rim_material.albedo_color = Color(0.48, 0.50, 0.52)
			rim_material.metallic = 0.78
			rim_material.roughness = 0.28
			rim.material_override = rim_material
			add_child(rim)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.0, 1.0, 4.0)
	collision.shape = shape
	collision.position.y = 0.5
	add_child(collision)

func _add_part(label: String, part_position: Vector3, dimensions: Vector3, color: Color) -> void:
	var part := MeshInstance3D.new()
	part.name = label
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	part.mesh = mesh
	part.position = part_position
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.32
	part.material_override = material
	add_child(part)

func _build_camera() -> void:
	vehicle_camera = Camera3D.new()
	vehicle_camera.name = "VehicleCamera"
	vehicle_camera.position = Vector3(0, 3.4, 7.2)
	vehicle_camera.rotation_degrees.x = -15.0
	vehicle_camera.fov = 76.0
	add_child(vehicle_camera)

func enter(player: CharacterBody3D) -> void:
	if driver != null:
		return
	driver = player
	just_entered = true
	driver.visible = false
	driver.set_physics_process(false)
	var player_collision := driver.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if player_collision != null:
		player_collision.set_deferred("disabled", true)
	vehicle_camera.current = true

func _physics_process(delta: float) -> void:
	if driver == null:
		return

	if Input.is_action_just_pressed("interact") and not just_entered:
		_exit_vehicle()
		return
	just_entered = false

	var throttle := Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	var steering := Input.get_action_strength("move_left") - Input.get_action_strength("move_right")

	if throttle > 0.0:
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)
	elif throttle < 0.0:
		current_speed = move_toward(current_speed, -reverse_speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0.0, acceleration * 0.65 * delta)

	if abs(current_speed) > 0.15:
		rotation.y += steering * steering_speed * delta * sign(current_speed)

	var forward := -global_basis.z
	velocity.x = forward.x * current_speed
	velocity.z = forward.z * current_speed
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0
	move_and_slide()

func _exit_vehicle() -> void:
	if driver == null:
		return
	var player := driver
	driver = null
	current_speed = 0.0
	player.global_position = global_position + global_basis.x * 2.4 + Vector3(0, 0.15, 0)
	player.set("velocity", Vector3.ZERO)
	player.visible = true
	var player_collision := player.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if player_collision != null:
		player_collision.set_deferred("disabled", false)
	player.set_physics_process(true)
	var player_camera := player.get_node_or_null("CameraPivot/PlayerCamera") as Camera3D
	if player_camera != null:
		player_camera.current = true
