extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")

func _ready() -> void:
	_build_environment()
	_build_city()
	_spawn_player()

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.62, 0.70, 0.82)
	environment.ambient_light_energy = 0.65
	world.environment = environment
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -32, 0)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	add_child(sun)

func _build_city() -> void:
	_add_box("Ground", Vector3(0, -0.25, 0), Vector3(120, 0.5, 120), Color(0.22, 0.30, 0.22))
	_add_box("Main road", Vector3(0, 0.02, 0), Vector3(12, 0.08, 120), Color(0.12, 0.13, 0.15))
	_add_box("Cross road", Vector3(0, 0.03, 0), Vector3(120, 0.08, 12), Color(0.12, 0.13, 0.15))

	for i in range(-2, 3):
		for j in range(-2, 3):
			if i == 0 and j == 0:
				continue
			var height := 5.0 + float(abs(i * 3 + j * 5) % 5) * 2.0
			var x := float(i) * 22.0
			var z := float(j) * 22.0
			var building_color := Color(0.48, 0.49, 0.50)
			if (i + j) % 3 == 0:
				building_color = Color(0.48, 0.34, 0.24)
			_add_box("Building", Vector3(x, height * 0.5, z), Vector3(10, height, 12), building_color)

func _add_box(label: String, position: Vector3, dimensions: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = label
	body.position = position
	add_child(body)

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	mesh_instance.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	mesh_instance.material_override = material
	body.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = dimensions
	collision.shape = shape
	body.add_child(collision)

func _spawn_player() -> void:
	var player := CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(0, 1.2, 18)
	player.set_script(PLAYER_SCRIPT)
	add_child(player)
