extends CharacterBody3D

@export var move_speed: float = 6.0

func _ready() -> void:
	var visual := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.42
	capsule.height = 1.8
	visual.mesh = capsule
	visual.position.y = 0.9
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.18, 0.34, 0.72)
	visual.material_override = material
	add_child(visual)

	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.42
	shape.height = 1.8
	collision.shape = shape
	collision.position.y = 0.9
	add_child(collision)

	var camera := Camera3D.new()
	camera.position = Vector3(0, 3.2, 6.0)
	camera.rotation_degrees.x = -18
	add_child(camera)
	camera.current = true

func _physics_process(delta: float) -> void:
	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	)
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	var direction := Vector3(input_vector.x, 0.0, input_vector.y)
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0

	move_and_slide()
