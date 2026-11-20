extends CharacterBody3D

@export_enum("dog", "cat", "parrot", "horse") var species: String = "dog"
@export var walk_speed: float = 1.8
@export var gravity: float = 9.8

var wander_direction := Vector3.ZERO
var change_direction_in := 0.0
var home_position := Vector3.ZERO
var body_material: StandardMaterial3D

func _ready() -> void:
	name = species.capitalize()
	add_to_group("animals")
	home_position = global_position
	_build_animal()
	_pick_direction()

func _build_animal() -> void:
	body_material = StandardMaterial3D.new()
	body_material.roughness = 0.9
	match species:
		"dog":
			body_material.albedo_color = Color(0.55, 0.31, 0.16)
			_add_ellipsoid("Body", Vector3(0, 0.62, 0), Vector3(0.48, 0.38, 0.78), body_material)
			_add_ellipsoid("Head", Vector3(0, 0.9, -0.62), Vector3(0.32, 0.32, 0.34), body_material)
			_add_ellipsoid("Snout", Vector3(0, 0.78, -0.91), Vector3(0.19, 0.16, 0.22), body_material)
			_add_legs(0.52, 0.25, Color(0.32, 0.19, 0.12))
		"cat":
			body_material.albedo_color = Color(0.58, 0.58, 0.54)
			_add_ellipsoid("Body", Vector3(0, 0.48, 0), Vector3(0.34, 0.31, 0.62), body_material)
			_add_ellipsoid("Head", Vector3(0, 0.83, -0.48), Vector3(0.29, 0.29, 0.29), body_material)
			_add_ellipsoid("Ear L", Vector3(-0.17, 1.08, -0.53), Vector3(0.10, 0.17, 0.09), body_material)
			_add_ellipsoid("Ear R", Vector3(0.17, 1.08, -0.53), Vector3(0.10, 0.17, 0.09), body_material)
			_add_legs(0.42, 0.22, Color(0.42, 0.42, 0.40))
		"horse":
			body_material.albedo_color = Color(0.34, 0.18, 0.10)
			_add_ellipsoid("Body", Vector3(0, 1.05, 0), Vector3(0.52, 0.58, 1.0), body_material)
			_add_ellipsoid("Neck", Vector3(0, 1.55, -0.68), Vector3(0.27, 0.65, 0.30), body_material)
			_add_ellipsoid("Head", Vector3(0, 1.92, -0.86), Vector3(0.24, 0.36, 0.25), body_material)
			_add_legs(1.0, 0.72, Color(0.20, 0.12, 0.08))
		"parrot":
			body_material.albedo_color = Color(0.08, 0.62, 0.28)
			_add_ellipsoid("Body", Vector3(0, 0.95, 0), Vector3(0.32, 0.48, 0.28), body_material)
			_add_ellipsoid("Head", Vector3(0, 1.42, -0.05), Vector3(0.29, 0.29, 0.29), body_material)
			var beak_material := StandardMaterial3D.new()
			beak_material.albedo_color = Color(0.95, 0.58, 0.08)
			_add_ellipsoid("Beak", Vector3(0, 1.36, -0.34), Vector3(0.12, 0.12, 0.18), beak_material)
			var wing_material := StandardMaterial3D.new()
			wing_material.albedo_color = Color(0.05, 0.28, 0.72)
			_add_ellipsoid("Wing L", Vector3(-0.30, 1.0, 0.02), Vector3(0.12, 0.30, 0.24), wing_material)
			_add_ellipsoid("Wing R", Vector3(0.30, 1.0, 0.02), Vector3(0.12, 0.30, 0.24), wing_material)

	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38 if species != "horse" else 0.52
	shape.height = 1.1 if species != "horse" else 2.2
	collision.shape = shape
	collision.position.y = shape.height * 0.5
	add_child(collision)

	var label := Label3D.new()
	label.text = species.capitalize()
	label.position.y = 2.3 if species == "horse" else 1.8
	label.font_size = 28
	label.modulate = Color(1, 1, 1, 0.85)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)

func _add_ellipsoid(part_name: String, part_position: Vector3, dimensions: Vector3, material: Material) -> void:
	var part := MeshInstance3D.new()
	part.name = part_name
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	part.mesh = mesh
	part.scale = dimensions * 2.0
	part.position = part_position
	part.material_override = material
	add_child(part)

func _add_legs(body_height: float, leg_length: float, color: Color) -> void:
	var leg_material := StandardMaterial3D.new()
	leg_material.albedo_color = color
	for x in [-0.25, 0.25]:
		for z in [-0.48, 0.48]:
			var leg := MeshInstance3D.new()
			var mesh := CylinderMesh.new()
			mesh.top_radius = 0.07
			mesh.bottom_radius = 0.09
			mesh.height = leg_length
			leg.mesh = mesh
			leg.position = Vector3(x, body_height - leg_length * 0.5, z)
			leg.material_override = leg_material
			add_child(leg)

func _pick_direction() -> void:
	var angle := randf_range(0.0, TAU)
	wander_direction = Vector3(cos(angle), 0.0, sin(angle))
	change_direction_in = randf_range(2.0, 5.0)

func _physics_process(delta: float) -> void:
	change_direction_in -= delta
	if change_direction_in <= 0.0 or global_position.distance_to(home_position) > 18.0:
		_pick_direction()

	if species == "parrot":
		velocity = wander_direction * (walk_speed * 1.8)
		velocity.y = sin(Time.get_ticks_msec() * 0.002) * 0.45
		global_position.y = maxf(global_position.y, 2.2)
		move_and_slide()
	else:
		velocity.x = wander_direction.x * walk_speed
		velocity.z = wander_direction.z * walk_speed
		if not is_on_floor():
			velocity.y -= gravity * delta
		else:
			velocity.y = 0.0
		move_and_slide()

	if Vector2(velocity.x, velocity.z).length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 3.0)
