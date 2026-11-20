extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const CAR_SCRIPT = preload("res://scripts/car.gd")
const SHOP_SCRIPT = preload("res://scripts/shop.gd")
const ANIMAL_SCRIPT = preload("res://scripts/animal.gd")
const CITIZEN_SCRIPT = preload("res://scripts/citizen.gd")
const TRAFFIC_SCRIPT = preload("res://scripts/traffic.gd")
const WORLD_CLOCK_SCRIPT = preload("res://scripts/world_clock.gd")
const TRAFFIC_SIGNAL_SCRIPT = preload("res://scripts/traffic_signal.gd")
const HOME_SCRIPT = preload("res://scripts/home.gd")
const CIVIC_BUILDING_SCRIPT = preload("res://scripts/civic_building.gd")

func _ready() -> void:
	_build_environment()
	_spawn_world_clock()
	_build_city()
	_build_road_details()
	_build_street_details()
	_build_outer_districts()
	_spawn_city_identity()
	_spawn_animals()
	_spawn_citizens()
	_spawn_traffic_signal()
	_spawn_traffic()
	_spawn_market_interaction()
	_spawn_home()
	_spawn_civic_buildings()
	_spawn_player()

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	world.name = "WorldEnvironment"
	var environment := Environment.new()
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.tonemap_exposure = 1.0
	environment.tonemap_white = 6.0
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.62, 0.70, 0.80)
	environment.fog_density = 0.0007
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.12, 0.25, 0.43)
	sky_material.sky_horizon_color = Color(0.62, 0.72, 0.82)
	sky_material.ground_bottom_color = Color(0.12, 0.14, 0.13)
	sky_material.ground_horizon_color = Color(0.48, 0.52, 0.50)
	sky_material.sun_angle_max = 18.0
	sky_material.sun_curve = 0.18
	sky.sky_material = sky_material
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.38
	world.environment = environment
	add_child(world)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-42, -55, 0)
	sun.light_energy = 1.55
	sun.light_color = Color(1.0, 0.94, 0.82)
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun.directional_shadow_max_distance = 75.0
	sun.directional_shadow_blend_splits = false
	sun.directional_shadow_split_1 = 0.08
	sun.directional_shadow_split_2 = 0.22
	sun.directional_shadow_split_3 = 0.55
	sun.shadow_bias = 0.02
	sun.shadow_normal_bias = 0.6
	sun.light_angular_distance = 0.0
	sun.shadow_opacity = 1.0
	add_child(sun)

func _build_city() -> void:
	_add_box("Ground", Vector3(0, -0.25, 0), Vector3(180, 0.5, 180), Color(0.22, 0.30, 0.22))
	_add_box("Main road", Vector3(0, 0.02, 0), Vector3(12, 0.08, 180), Color(0.12, 0.13, 0.15))
	_add_box("Cross road", Vector3(0, 0.03, 0), Vector3(180, 0.08, 12), Color(0.12, 0.13, 0.15))

	var asphalt_noise := FastNoiseLite.new()
	asphalt_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	asphalt_noise.frequency = 0.075
	asphalt_noise.fractal_octaves = 3
	var asphalt_texture := NoiseTexture2D.new()
	asphalt_texture.width = 256
	asphalt_texture.height = 256
	asphalt_texture.noise = asphalt_noise
	var asphalt_material := StandardMaterial3D.new()
	asphalt_material.albedo_color = Color(0.42, 0.43, 0.45)
	asphalt_material.albedo_texture = asphalt_texture
	asphalt_material.roughness = 0.98
	_add_visual_box("Textured asphalt north south", Vector3(0, 0.066, 0), Vector3(11.9, 0.012, 180), asphalt_material)
	_add_visual_box("Textured asphalt east west", Vector3(0, 0.067, 0), Vector3(180, 0.012, 11.9), asphalt_material)

	var grass_noise := FastNoiseLite.new()
	grass_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	grass_noise.frequency = 0.035
	grass_noise.fractal_octaves = 4
	var grass_texture := NoiseTexture2D.new()
	grass_texture.width = 256
	grass_texture.height = 256
	grass_texture.noise = grass_noise
	var grass_material := StandardMaterial3D.new()
	grass_material.albedo_color = Color(0.58, 0.66, 0.48)
	grass_material.albedo_texture = grass_texture
	grass_material.roughness = 1.0
	_add_visual_box("Procedural grass surface", Vector3(0, 0.006, 0), Vector3(180, 0.01, 180), grass_material)

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
			_add_building_facade(x, z, height)



func _add_building_facade(x: float, z: float, height: float) -> void:
	var glass := StandardMaterial3D.new()
	glass.albedo_color = Color(0.055, 0.15, 0.22)
	glass.metallic = 0.42
	glass.roughness = 0.16
	glass.clearcoat_enabled = true
	glass.clearcoat = 0.55
	var frame := StandardMaterial3D.new()
	frame.albedo_color = Color(0.72, 0.70, 0.64)
	frame.roughness = 0.82
	var dark_frame := StandardMaterial3D.new()
	dark_frame.albedo_color = Color(0.12, 0.15, 0.17)
	dark_frame.roughness = 0.62
	var floors := int(height / 3.0)
	for floor_index in range(floors):
		var window_y := 1.8 + float(floor_index) * 3.0
		for window_x in [-3.1, 0.0, 3.1]:
			_add_visual_box("Front building window", Vector3(x + window_x, window_y, z - 6.08), Vector3(2.0, 1.45, 0.10), glass)
			_add_visual_box("Back building window", Vector3(x + window_x, window_y, z + 6.08), Vector3(2.0, 1.45, 0.10), glass)
			_add_visual_box("Front window sill", Vector3(x + window_x, window_y - 0.78, z - 6.12), Vector3(2.15, 0.10, 0.16), frame)
			_add_visual_box("Back window sill", Vector3(x + window_x, window_y - 0.78, z + 6.12), Vector3(2.15, 0.10, 0.16), frame)
			_add_visual_box("Front window mullion", Vector3(x + window_x, window_y, z - 6.145), Vector3(0.055, 1.42, 0.035), dark_frame)
			_add_visual_box("Back window mullion", Vector3(x + window_x, window_y, z + 6.145), Vector3(0.055, 1.42, 0.035), dark_frame)
		for window_z in [-3.2, 0.0, 3.2]:
			_add_visual_box("Left building window", Vector3(x - 5.08, window_y, z + window_z), Vector3(0.10, 1.45, 2.0), glass)
			_add_visual_box("Right building window", Vector3(x + 5.08, window_y, z + window_z), Vector3(0.10, 1.45, 2.0), glass)
			_add_visual_box("Left window mullion", Vector3(x - 5.145, window_y, z + window_z), Vector3(0.035, 1.42, 0.055), dark_frame)
			_add_visual_box("Right window mullion", Vector3(x + 5.145, window_y, z + window_z), Vector3(0.035, 1.42, 0.055), dark_frame)
		_add_visual_box("Front floor facade trim", Vector3(x, window_y + 1.05, z - 6.03), Vector3(9.8, 0.10, 0.12), frame)
		_add_visual_box("Back floor facade trim", Vector3(x, window_y + 1.05, z + 6.03), Vector3(9.8, 0.10, 0.12), frame)
		_add_visual_box("Left floor facade trim", Vector3(x - 5.03, window_y + 1.05, z), Vector3(0.12, 0.10, 11.8), frame)
		_add_visual_box("Right floor facade trim", Vector3(x + 5.03, window_y + 1.05, z), Vector3(0.12, 0.10, 11.8), frame)
		# Pequenas sacadas com guarda-corpo metálico para quebrar a repetição das fachadas.
		if floor_index > 0 and floor_index % 2 == 0:
			for balcony_x in [-3.1, 3.1]:
				_add_visual_box("Balcony slab", Vector3(x + balcony_x, window_y - 0.82, z - 6.32), Vector3(2.25, 0.12, 0.62), dark_frame)
				_add_visual_box("Balcony rail", Vector3(x + balcony_x, window_y - 0.35, z - 6.58), Vector3(2.20, 0.72, 0.055), frame)
	# Base comercial, rodapé e detalhes de cobertura.
	_add_visual_box("Building base band", Vector3(x, 0.38, z - 6.10), Vector3(10.0, 0.42, 0.22), dark_frame)
	_add_visual_box("Building base band back", Vector3(x, 0.38, z + 6.10), Vector3(10.0, 0.42, 0.22), dark_frame)
	_add_visual_box("Roof parapet front", Vector3(x, height + 0.18, z - 5.95), Vector3(10.0, 0.36, 0.28), frame)
	_add_visual_box("Roof parapet back", Vector3(x, height + 0.18, z + 5.95), Vector3(10.0, 0.36, 0.28), frame)
	_add_visual_box("Roof parapet left", Vector3(x - 4.9, height + 0.18, z), Vector3(0.28, 0.36, 12.0), frame)
	_add_visual_box("Roof parapet right", Vector3(x + 4.9, height + 0.18, z), Vector3(0.28, 0.36, 12.0), frame)
	# Equipamentos de ar-condicionado e ventilação no topo.
	for roof_x in [-3.0, 3.0]:
		_add_visual_box("Rooftop HVAC unit", Vector3(x + roof_x, height + 0.48, z + 2.8), Vector3(1.35, 0.62, 1.0), dark_frame)
		_add_visual_box("Rooftop HVAC top", Vector3(x + roof_x, height + 0.81, z + 2.8), Vector3(1.42, 0.08, 1.06), frame)
	# Marquise na entrada e pilares laterais da fachada principal.
	_add_visual_box("Ground floor canopy", Vector3(x, 3.05, z - 6.55), Vector3(9.6, 0.18, 1.0), dark_frame)
	for column_x in [-4.45, 4.45]:
		_add_visual_box("Facade entrance column", Vector3(x + column_x, 1.55, z - 6.18), Vector3(0.28, 3.1, 0.32), frame)

func _build_outer_districts() -> void:
	_add_district_building("ESCOLA MUNICIPAL", Vector3(-65, 3.2, -62), Vector3(18, 6.4, 14), Color(0.72, 0.62, 0.38))
	_add_district_building("HOSPITAL", Vector3(65, 4.0, -62), Vector3(18, 8.0, 14), Color(0.72, 0.76, 0.78))
	_add_district_building("RESTAURANTE", Vector3(-65, 2.8, 62), Vector3(18, 5.6, 14), Color(0.55, 0.27, 0.18))
	_add_district_building("CENTRO COMERCIAL", Vector3(65, 4.5, 62), Vector3(20, 9.0, 16), Color(0.30, 0.38, 0.48))
	_add_box("School entrance", Vector3(-65, 1.1, -54.85), Vector3(3.0, 2.2, 0.18), Color(0.20, 0.16, 0.10))
	_add_box("Hospital entrance", Vector3(65, 1.2, -54.85), Vector3(3.0, 2.4, 0.18), Color(0.18, 0.35, 0.42))
	_add_box("Restaurant entrance", Vector3(-65, 1.1, 69.15), Vector3(3.0, 2.2, 0.18), Color(0.20, 0.12, 0.08))
	_add_box("Shopping entrance", Vector3(65, 1.2, 70.15), Vector3(3.0, 2.4, 0.18), Color(0.12, 0.18, 0.25))
	_add_district_sign("DISTRITO ESCOLAR", Vector3(-65, 7.4, -52))
	_add_district_sign("DISTRITO DE SAÚDE", Vector3(65, 9.0, -52))
	_add_district_sign("BAIRRO GASTRONÔMICO", Vector3(-65, 6.5, 77))
	_add_district_sign("CENTRO COMERCIAL", Vector3(65, 10.0, 78))

func _add_district_building(label: String, position: Vector3, dimensions: Vector3, color: Color) -> void:
	_add_box(label, position, dimensions, color)
	var front_z := position.z + dimensions.z * 0.5 + 0.08
	for window_x in [-5.5, 0.0, 5.5]:
		_add_box(label + " window", Vector3(position.x + window_x, position.y + 0.7, front_z), Vector3(2.2, 1.8, 0.12), Color(0.12, 0.28, 0.38))

func _add_district_sign(label: String, position: Vector3) -> void:
	var sign := Label3D.new()
	sign.text = label
	sign.position = position
	sign.font_size = 38
	sign.modulate = Color(1.0, 0.88, 0.58)
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(sign)

func _build_road_details() -> void:
	var sidewalk_material := StandardMaterial3D.new()
	sidewalk_material.albedo_color = Color(0.42, 0.43, 0.42)
	sidewalk_material.roughness = 0.95
	_add_visual_box("Sidewalk west", Vector3(-7.4, 0.10, 0), Vector3(2.4, 0.20, 180), sidewalk_material)
	_add_visual_box("Sidewalk east", Vector3(7.4, 0.10, 0), Vector3(2.4, 0.20, 180), sidewalk_material)
	_add_visual_box("Sidewalk north", Vector3(0, 0.10, -7.4), Vector3(180, 0.20, 2.4), sidewalk_material)
	_add_visual_box("Sidewalk south", Vector3(0, 0.10, 7.4), Vector3(180, 0.20, 2.4), sidewalk_material)

	var stripe_material := StandardMaterial3D.new()
	stripe_material.albedo_color = Color(0.88, 0.88, 0.82)
	for stripe_x in [-5.0, -3.0, -1.0, 1.0, 3.0, 5.0]:
		_add_visual_box("Crosswalk stripe", Vector3(stripe_x, 0.10, -7.2), Vector3(1.0, 0.035, 2.2), stripe_material)
		_add_visual_box("Crosswalk stripe", Vector3(stripe_x, 0.10, 7.2), Vector3(1.0, 0.035, 2.2), stripe_material)
	for stripe_z in [-5.0, -3.0, -1.0, 1.0, 3.0, 5.0]:
		_add_visual_box("Crosswalk stripe", Vector3(-7.2, 0.10, stripe_z), Vector3(2.2, 0.035, 1.0), stripe_material)
		_add_visual_box("Crosswalk stripe", Vector3(7.2, 0.10, stripe_z), Vector3(2.2, 0.035, 1.0), stripe_material)

	var lane_paint := StandardMaterial3D.new()
	lane_paint.albedo_color = Color(0.88, 0.82, 0.58)
	lane_paint.roughness = 0.95
	for dash_z in range(-80, 81, 12):
		_add_visual_box("Road center dash", Vector3(0, 0.085, float(dash_z)), Vector3(0.16, 0.025, 5.5), lane_paint)
	for dash_x in range(-80, 81, 12):
		_add_visual_box("Road center dash", Vector3(float(dash_x), 0.085, 0), Vector3(5.5, 0.025, 0.16), lane_paint)

	for lamp_position in [Vector3(-9.0, 0.0, -9.0), Vector3(9.0, 0.0, -9.0), Vector3(-9.0, 0.0, 9.0), Vector3(9.0, 0.0, 9.0)]:
		_add_street_lamp(lamp_position)

func _add_visual_box(label: String, position: Vector3, dimensions: Vector3, material: Material) -> void:
	var visual := MeshInstance3D.new()
	visual.name = label
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	visual.mesh = mesh
	visual.position = position
	visual.material_override = material
	add_child(visual)

func _add_street_lamp(position: Vector3) -> void:
	var pole := MeshInstance3D.new()
	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = 0.07
	pole_mesh.bottom_radius = 0.11
	pole_mesh.height = 5.2
	pole.mesh = pole_mesh
	pole.position = position + Vector3(0, 2.6, 0)
	var pole_material := StandardMaterial3D.new()
	pole_material.albedo_color = Color(0.10, 0.12, 0.15)
	pole.material_override = pole_material
	add_child(pole)

	var arm := MeshInstance3D.new()
	var arm_mesh := BoxMesh.new()
	arm_mesh.size = Vector3(1.1, 0.10, 0.10)
	arm.mesh = arm_mesh
	arm.position = position + Vector3(0.48, 5.0, 0)
	arm.material_override = pole_material
	add_child(arm)

	var lamp := OmniLight3D.new()
	lamp.position = position + Vector3(0.92, 4.85, 0)
	lamp.light_color = Color(1.0, 0.82, 0.58)
	lamp.light_energy = 0.9
	lamp.omni_range = 13.0
	lamp.shadow_enabled = true
	lamp.shadow_bias = 0.08
	add_child(lamp)

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

func _spawn_world_clock() -> void:
	var clock := Node.new()
	clock.name = "WorldClock"
	clock.set_script(WORLD_CLOCK_SCRIPT)
	add_child(clock)

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
	var work_spot := spawn_position + Vector3(5, 0, -2)
	var leisure_spot := spawn_position + Vector3(-3, 0, 6)
	match job:
		"Barista":
			work_spot = Vector3(-19, 0, 11)
			leisure_spot = Vector3(-5, 0, 28)
		"Mecânico":
			work_spot = Vector3(14, 0, 15)
			leisure_spot = Vector3(0, 0, -18)
		"Jardineira":
			work_spot = Vector3(0, 0, -18)
			leisure_spot = Vector3(8, 0, -8)
		"Entregador":
			work_spot = Vector3(-24, 0, -22)
			leisure_spot = Vector3(-8, 0, 28)
	citizen.set("work_position", work_spot)
	citizen.set("leisure_position", leisure_spot)
	add_child(citizen)


func _spawn_traffic_signal() -> void:
	var traffic_signal := Node3D.new()
	traffic_signal.name = "MainTrafficSignal"
	traffic_signal.set_script(TRAFFIC_SIGNAL_SCRIPT)
	add_child(traffic_signal)

func _spawn_traffic() -> void:
	# Carros autônomos circulam pelas duas avenidas do bairro.
	_spawn_traffic_car(Vector3(-2.2, 0.0, -48.0), Vector3(0, 0, 1), 8.0, Color(0.72, 0.16, 0.12))
	_spawn_traffic_car(Vector3(2.2, 0.0, 28.0), Vector3(0, 0, -1), 6.5, Color(0.16, 0.32, 0.68))
	_spawn_traffic_car(Vector3(-32.0, 0.0, -2.2), Vector3(1, 0, 0), 7.2, Color(0.72, 0.68, 0.52))
	_spawn_traffic_car(Vector3(42.0, 0.0, 2.2), Vector3(-1, 0, 0), 8.5, Color(0.18, 0.48, 0.30))
	_spawn_traffic_car(Vector3(2.2, 0.0, -8.0), Vector3(0, 0, -1), 7.5, Color(0.48, 0.28, 0.62))
	_spawn_traffic_car(Vector3(-48.0, 0.0, 2.2), Vector3(1, 0, 0), 6.0, Color(0.72, 0.38, 0.12))
	_spawn_traffic_vehicle(Vector3(-2.2, 0.0, 48.0), Vector3(0, 0, -1), 5.2, Color(0.78, 0.68, 0.22), "bus")
	_spawn_traffic_vehicle(Vector3(2.2, 0.0, -38.0), Vector3(0, 0, 1), 9.5, Color(0.82, 0.24, 0.12), "motorcycle")
	_spawn_traffic_vehicle(Vector3(36.0, 0.0, -2.2), Vector3(-1, 0, 0), 10.0, Color(0.16, 0.18, 0.20), "motorcycle")

func _spawn_traffic_car(spawn_position: Vector3, axis: Vector3, speed: float, paint: Color) -> void:
	_spawn_traffic_vehicle(spawn_position, axis, speed, paint, "car")

func _spawn_traffic_vehicle(spawn_position: Vector3, axis: Vector3, speed: float, paint: Color, kind: String) -> void:
	var traffic_vehicle := CharacterBody3D.new()
	traffic_vehicle.position = spawn_position
	traffic_vehicle.set_script(TRAFFIC_SCRIPT)
	traffic_vehicle.set("travel_axis", axis)
	traffic_vehicle.set("travel_speed", speed)
	traffic_vehicle.set("lane_offset", Vector3(spawn_position.x, 0.0, spawn_position.z) - axis * spawn_position.dot(axis))
	traffic_vehicle.set("route_min", -54.0)
	traffic_vehicle.set("route_max", 54.0)
	traffic_vehicle.set("vehicle_color", paint)
	traffic_vehicle.set("vehicle_type", kind)
	add_child(traffic_vehicle)

func _spawn_home() -> void:
	var home := Node3D.new()
	home.name = "StarterHome"
	home.position = Vector3(19, 0, 17)
	home.set_script(HOME_SCRIPT)
	add_child(home)

func _spawn_civic_buildings() -> void:
	_spawn_civic_building("school", "Escola Municipal", Vector3(-65, 0, -62), Vector3(130, 0, 130))
	_spawn_civic_building("hospital", "Hospital", Vector3(65, 0, -62), Vector3(160, 0, 130))
	_spawn_civic_building("restaurant", "Restaurante", Vector3(-65, 0, 62), Vector3(130, 0, 160))
	_spawn_civic_building("mall", "Centro Comercial", Vector3(65, 0, 62), Vector3(160, 0, 160))

func _spawn_civic_building(kind: String, label: String, world_position: Vector3, room_position: Vector3) -> void:
	var building := Node3D.new()
	building.name = label.replace(" ", "")
	building.position = world_position
	building.set_script(CIVIC_BUILDING_SCRIPT)
	building.set("building_type", kind)
	building.set("display_name", label)
	building.set("interior_origin", room_position)
	add_child(building)
