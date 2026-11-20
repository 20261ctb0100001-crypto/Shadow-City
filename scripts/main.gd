extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const CAR_SCRIPT = preload("res://scripts/car.gd")
const SHOP_SCRIPT = preload("res://scripts/shop.gd")
const ANIMAL_SCRIPT = preload("res://scripts/animal.gd")
const CITIZEN_SCRIPT = preload("res://scripts/citizen.gd")

func _ready() -> void:
	_build_environment()
	_build_city()
	_build_street_details()
	_spawn_city_identity()
	_spawn_animals()
	_spawn_citizens()
	_spawn_market_interaction()
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
			if (i == 0 and j == 0) or (j == 1 and abs(i) == 1):
				continue
			var height := 5.0 + float(abs(i * 3 + j * 5) % 5) * 2.0
			var x := float(i) * 22.0
			var z := float(j) * 22.0
			var building_color := Color(0.48, 0.49, 0.50)
			if (i + j) % 3 == 0:
				building_color = Color(0.48, 0.34, 0.24)
			_add_box("Building", Vector3(x, height * 0.5, z), Vector3(10, height, 12), building_color)

func _build_street_details() -> void:
	# Small wooden house to establish the residential look.
	_add_box("Wooden house", Vector3(19, 2.4, 17), Vector3(9, 4.8, 8), Color(0.43, 0.25, 0.14))
	_add_box("House roof", Vector3(19, 5.1, 17), Vector3(10, 0.55, 9), Color(0.16, 0.18, 0.21))
	_add_box("Front door", Vector3(19, 1.1, 12.94), Vector3(1.5, 2.2, 0.12), Color(0.20, 0.12, 0.08))
	_add_box("Front window left", Vector3(16.3, 2.8, 12.90), Vector3(1.8, 1.5, 0.12), Color(0.12, 0.25, 0.34))
	_add_box("Front window right", Vector3(21.7, 2.8, 12.90), Vector3(1.8, 1.5, 0.12), Color(0.12, 0.25, 0.34))

	# A simple storefront with a sign.
	_add_box("Market building", Vector3(-19, 2.5, 17), Vector3(10, 5, 8), Color(0.68, 0.65, 0.56))
	_add_box("Market glass", Vector3(-19, 2.0, 12.90), Vector3(6.5, 2.5, 0.12), Color(0.10, 0.25, 0.32))
	var sign := Label3D.new()
	sign.text = "MARKET"
	sign.position = Vector3(-19, 4.2, 12.7)
	sign.font_size = 64
	sign.modulate = Color(1.0, 0.88, 0.55)
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(sign)

	for x in [-8.0, 8.0]:
		_add_tree(Vector3(x, 0, 10))
		_add_tree(Vector3(x, 0, -10))
		_add_tree(Vector3(x, 0, 28))

func _add_tree(position: Vector3) -> void:
	var trunk := MeshInstance3D.new()
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.18
	trunk_mesh.bottom_radius = 0.28
	trunk_mesh.height = 2.2
	trunk.mesh = trunk_mesh
	trunk.position = position + Vector3(0, 1.1, 0)
	var trunk_material := StandardMaterial3D.new()
	trunk_material.albedo_color = Color(0.28, 0.17, 0.10)
	trunk.material_override = trunk_material
	add_child(trunk)

	var leaves := MeshInstance3D.new()
	var leaves_mesh := SphereMesh.new()
	leaves_mesh.radius = 1.25
	leaves_mesh.height = 2.5
	leaves.mesh = leaves_mesh
	leaves.position = position + Vector3(0, 2.8, 0)
	var leaves_material := StandardMaterial3D.new()
	leaves_material.albedo_color = Color(0.12, 0.30, 0.16)
	leaves_material.roughness = 1.0
	leaves.material_override = leaves_material
	add_child(leaves)

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

	var car := CharacterBody3D.new()
	car.name = "PlayerCar"
	car.position = Vector3(3.5, 0.0, 18)
	car.set_script(CAR_SCRIPT)
	add_child(car)

func _spawn_market_interaction() -> void:
	var shop := Node3D.new()
	shop.name = "ClothingShop"
	shop.position = Vector3(-19, 0, 17)
	shop.set_script(SHOP_SCRIPT)
	add_child(shop)

func _spawn_city_identity() -> void:
	var city_sign := Label3D.new()
	city_sign.text = "PONTA GROSSA  •  PARANÁ  •  BRASIL"
	city_sign.position = Vector3(0, 3.2, -7.5)
	city_sign.font_size = 42
	city_sign.modulate = Color(0.82, 0.90, 1.0)
	city_sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(city_sign)

func _spawn_animals() -> void:
	_spawn_animal("dog", Vector3(6, 0.0, 12), 1.7)
	_spawn_animal("cat", Vector3(-5, 0.0, 16), 1.1)
	_spawn_animal("parrot", Vector3(10, 2.4, -5), 1.5)
	_spawn_animal("horse", Vector3(27, 0.0, -18), 1.2)

func _spawn_animal(species: String, spawn_position: Vector3, speed: float) -> void:
	var animal := CharacterBody3D.new()
	animal.position = spawn_position
	animal.set_script(ANIMAL_SCRIPT)
	animal.set("species", species)
	animal.set("walk_speed", speed)
	add_child(animal)

func _spawn_citizens() -> void:
	_spawn_citizen("Marina", "Barista", "Simpática e comunicativa", "Oi! Trabalho no café. Quer fazer um turno comigo?", 85, Vector3(-11, 0, 7), Color(0.22, 0.42, 0.72), 1.0)
	_spawn_citizen("João", "Mecânico", "Prático, paciente e detalhista", "Meu nome é João. A oficina precisa de ajuda hoje.", 110, Vector3(12, 0, 8), Color(0.78, 0.38, 0.16), 0.8)
	_spawn_citizen("Lia", "Jardineira", "Tranquila e gosta da natureza", "Estou cuidando da praça. Tem um turno disponível.", 70, Vector3(8, 0, -13), Color(0.25, 0.58, 0.32), 1.2)
	_spawn_citizen("Carlos", "Entregador", "Agitado, engraçado e pontual", "Preciso de uma mão com as entregas do bairro!", 95, Vector3(-26, 0, -16), Color(0.62, 0.28, 0.25), 1.6)

func _spawn_citizen(person_name: String, job: String, traits: String, line: String, reward: int, spawn_position: Vector3, outfit: Color, speed: float) -> void:
	var citizen := CharacterBody3D.new()
	citizen.position = spawn_position
	citizen.set_script(CITIZEN_SCRIPT)
	citizen.set("display_name", person_name)
	citizen.set("profession", job)
	citizen.set("personality", traits)
	citizen.set("dialogue", line)
	citizen.set("shift_reward", reward)
	citizen.set("favorite_color", outfit)
	citizen.set("walk_speed", speed)
	add_child(citizen)
