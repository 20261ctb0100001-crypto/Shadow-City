extends CharacterBody3D

@export var move_speed: float = 5.5
@export var gravity: float = 9.8

var camera: Camera3D
var body_collision: CollisionShape3D
var outfit_material: StandardMaterial3D
var money: int = 250
var money_label: Label
var save_timer: float = 0.0
var needs_timer: float = 0.0
var hunger: float = 100.0
var energy: float = 100.0
var hygiene: float = 100.0
var study_points: int = 0
var needs_label: Label
var needs_menu: CanvasLayer
const SAVE_PATH := "user://shadow_city_save.cfg"

func _ready() -> void:
	_create_placeholder_character()
	_create_camera()
	_create_mobile_controls()
	_load_progress()
	_create_money_display()
	_create_needs_display()
	tree_exiting.connect(_save_progress)

func _create_placeholder_character() -> void:
	# Silhueta humana provisória, substituível por um modelo 3D rigado.
	outfit_material = StandardMaterial3D.new()
	outfit_material.albedo_color = Color(0.12, 0.22, 0.38)
	outfit_material.roughness = 0.72
	outfit_material.metallic = 0.0

	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.72, 0.49, 0.34)
	skin.roughness = 0.86
	var pants := StandardMaterial3D.new()
	pants.albedo_color = Color(0.10, 0.13, 0.18)
	pants.roughness = 0.9
	var shoes := StandardMaterial3D.new()
	shoes.albedo_color = Color(0.035, 0.04, 0.05)
	shoes.roughness = 0.95

	_add_character_part("Torso", CapsuleMesh.new(), Vector3(0, 1.12, 0), Vector3(0.48, 0.72, 0.40), outfit_material)
	_add_character_part("Head", SphereMesh.new(), Vector3(0, 1.78, 0), Vector3(0.27, 0.29, 0.25), skin)
	_add_character_part("Hair", SphereMesh.new(), Vector3(0, 1.91, -0.015), Vector3(0.275, 0.16, 0.25), shoes)
	_add_character_part("LeftArm", CapsuleMesh.new(), Vector3(-0.34, 1.13, 0), Vector3(0.13, 0.48, 0.13), outfit_material)
	_add_character_part("RightArm", CapsuleMesh.new(), Vector3(0.34, 1.13, 0), Vector3(0.13, 0.48, 0.13), outfit_material)
	_add_character_part("LeftHand", SphereMesh.new(), Vector3(-0.34, 0.83, 0), Vector3(0.12, 0.13, 0.12), skin)
	_add_character_part("RightHand", SphereMesh.new(), Vector3(0.34, 0.83, 0), Vector3(0.12, 0.13, 0.12), skin)
	_add_character_part("LeftLeg", CapsuleMesh.new(), Vector3(-0.14, 0.48, 0), Vector3(0.15, 0.55, 0.15), pants)
	_add_character_part("RightLeg", CapsuleMesh.new(), Vector3(0.14, 0.48, 0), Vector3(0.15, 0.55, 0.15), pants)
	_add_character_part("LeftShoe", BoxMesh.new(), Vector3(-0.14, 0.12, -0.07), Vector3(0.20, 0.13, 0.34), shoes)
	_add_character_part("RightShoe", BoxMesh.new(), Vector3(0.14, 0.12, -0.07), Vector3(0.20, 0.13, 0.34), shoes)

	body_collision = CollisionShape3D.new()
	body_collision.name = "CollisionShape3D"
	var shape := CapsuleShape3D.new()
	shape.radius = 0.30
	shape.height = 1.85
	body_collision.shape = shape
	body_collision.position.y = 0.93
	add_child(body_collision)

func _add_character_part(part_name: String, mesh_resource: Resource, part_position: Vector3, part_scale: Vector3, material: Material) -> void:
	var part := MeshInstance3D.new()
	part.name = part_name
	part.mesh = mesh_resource
	part.position = part_position
	part.scale = part_scale
	part.material_override = material
	add_child(part)

func _create_camera() -> void:
	var pivot := Node3D.new()
	pivot.name = "CameraPivot"
	pivot.position.y = 1.45
	add_child(pivot)

	camera = Camera3D.new()
	camera.name = "PlayerCamera"
	camera.position = Vector3(0, 2.1, 6.0)
	camera.rotation_degrees.x = -16.0
	camera.fov = 72.0
	pivot.add_child(camera)
	camera.current = true

func _create_money_display() -> void:
	var layer := get_node_or_null("MobileControls") as CanvasLayer
	if layer == null:
		return
	money_label = Label.new()
	money_label.text = "DINHEIRO: $" + str(money)
	money_label.position = Vector2(18, 42)
	money_label.add_theme_font_size_override("font_size", 20)
	money_label.add_theme_color_override("font_color", Color(0.72, 1.0, 0.72))
	layer.add_child(money_label)

func add_money(amount: int) -> void:
	money += amount
	_update_money_display()
	_save_progress()

func _load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	money = int(config.get_value("player", "money", money))
	global_position = config.get_value("player", "position", global_position)
	var saved_color: Color = config.get_value("player", "outfit_color", Color(0.16, 0.30, 0.58))
	outfit_material.albedo_color = saved_color
	hunger = float(config.get_value("player", "hunger", hunger))
	energy = float(config.get_value("player", "energy", energy))
	hygiene = float(config.get_value("player", "hygiene", hygiene))
	study_points = int(config.get_value("player", "study_points", study_points))

func _save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("player", "money", money)
	config.set_value("player", "position", global_position)
	config.set_value("player", "outfit_color", outfit_material.albedo_color)
	config.set_value("player", "hunger", hunger)
	config.set_value("player", "energy", energy)
	config.set_value("player", "hygiene", hygiene)
	config.set_value("player", "study_points", study_points)
	var error := config.save(SAVE_PATH)
	if error != OK:
		push_warning("Não foi possível salvar o progresso do Shadow City.")

func _process(delta: float) -> void:
	save_timer += delta
	if save_timer >= 10.0:
		save_timer = 0.0
		_save_progress()
	needs_timer += delta
	if needs_timer >= 1.0:
		needs_timer = 0.0
		hunger = maxf(0.0, hunger - 0.035)
		energy = maxf(0.0, energy - 0.025)
		hygiene = maxf(0.0, hygiene - 0.018)
		_update_needs_display()
		_update_life_menu_status()

func _create_needs_display() -> void:
	needs_label = Label.new()
	needs_label.position = Vector2(18, 70)
	needs_label.add_theme_font_size_override("font_size", 17)
	needs_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.62))
	var layer := get_node_or_null("MobileControls") as CanvasLayer
	if layer != null:
		layer.add_child(needs_label)
	_update_needs_display()

func _update_needs_display() -> void:
	if needs_label != null:
		needs_label.text = "FOME %d%%  •  ENERGIA %d%%  •  HIGIENE %d%%" % [roundi(hunger), roundi(energy), roundi(hygiene)]

func _add_life_button(root: Control) -> void:
	var button := Button.new()
	button.text = "VIDA"
	button.position = Vector2(get_viewport().get_visible_rect().size.x - 250, get_viewport().get_visible_rect().size.y - 104)
	button.size = Vector2(108, 76)
	button.add_theme_font_size_override("font_size", 19)
	button.add_theme_stylebox_override("normal", _button_style(Color(0.12, 0.28, 0.20, 0.88)))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.20, 0.48, 0.30, 0.95)))
	button.focus_mode = Control.FOCUS_NONE
	root.add_child(button)
	button.pressed.connect(_open_life_menu)

func _open_life_menu() -> void:
	if needs_menu != null:
		return
	needs_menu = CanvasLayer.new()
	get_tree().root.add_child(needs_menu)
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.01, 0.02, 0.04, 0.78)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	needs_menu.add_child(backdrop)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	needs_menu.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 340)
	center.add_child(panel)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	panel.add_child(layout)
	var title := Label.new()
	title.text = "NECESSIDADES DO PERSONAGEM"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	layout.add_child(title)
	var status := Label.new()
	status.name = "NeedsStatus"
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(status)
	var eat := Button.new()
	eat.text = "Comer uma refeição  •  $15"
	eat.custom_minimum_size = Vector2(0, 48)
	layout.add_child(eat)
	eat.pressed.connect(func() -> void:
		if money < 15:
			status.text = "Dinheiro insuficiente para comprar comida."
			return
		money -= 15
		hunger = minf(100.0, hunger + 38.0)
		_update_money_display()
		_update_needs_display()
		status.text = "Você comeu. Fome recuperada!"
		_save_progress()
	)
	var rest := Button.new()
	rest.text = "Descansar"
	rest.custom_minimum_size = Vector2(0, 48)
	layout.add_child(rest)
	rest.pressed.connect(func() -> void:
		energy = minf(100.0, energy + 45.0)
		_update_needs_display()
		status.text = "Você descansou e recuperou energia."
		_save_progress()
	)
	var shower := Button.new()
	shower.text = "Tomar banho"
	shower.custom_minimum_size = Vector2(0, 48)
	layout.add_child(shower)
	shower.pressed.connect(func() -> void:
		hygiene = 100.0
		_update_needs_display()
		status.text = "Higiene restaurada."
		_save_progress()
	)
	var close := Button.new()
	close.text = "Fechar"
	close.custom_minimum_size = Vector2(0, 42)
	layout.add_child(close)
	close.pressed.connect(func() -> void:
		if needs_menu != null:
			needs_menu.queue_free()
			needs_menu = null
	)
	_update_life_menu_status()

func _update_life_menu_status() -> void:
	if needs_menu == null:
		return
	var status := needs_menu.find_child("NeedsStatus", true, false) as Label
	if status != null:
		status.text = "Fome: %d%%   Energia: %d%%   Higiene: %d%%" % [roundi(hunger), roundi(energy), roundi(hygiene)]

func _update_money_display() -> void:
	if money_label != null:
		money_label.text = "DINHEIRO: $" + str(money)

func _create_mobile_controls() -> void:
	var layer := CanvasLayer.new()
	layer.name = "MobileControls"
	add_child(layer)

	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(root)

	_add_touch_button(root, "↑", "move_forward", Vector2(104, -174))
	_add_touch_button(root, "↓", "move_backward", Vector2(104, -76))
	_add_touch_button(root, "←", "move_left", Vector2(8, -76))
	_add_touch_button(root, "→", "move_right", Vector2(200, -76))
	_add_interact_button(root)
	_add_life_button(root)

	var hint := Label.new()
	hint.text = "SHADOW CITY  •  TEST BUILD"
	hint.position = Vector2(18, 16)
	hint.add_theme_font_size_override("font_size", 18)
	hint.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.9))
	root.add_child(hint)

func _add_interact_button(root: Control) -> void:
	var button := Button.new()
	button.text = "AÇÃO"
	button.position = Vector2(get_viewport().get_visible_rect().size.x - 126, get_viewport().get_visible_rect().size.y - 104)
	button.size = Vector2(108, 76)
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_stylebox_override("normal", _button_style(Color(0.30, 0.18, 0.08, 0.85)))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.58, 0.32, 0.10, 0.95)))
	button.focus_mode = Control.FOCUS_NONE
	root.add_child(button)
	button.button_down.connect(func() -> void: Input.action_press("interact"))
	button.button_up.connect(func() -> void: Input.action_release("interact"))

func _add_touch_button(root: Control, caption: String, action_name: String, offset: Vector2) -> void:
	var button := Button.new()
	button.text = caption
	button.position = Vector2(offset.x, get_viewport().get_visible_rect().size.y + offset.y)
	button.size = Vector2(88, 88)
	button.add_theme_font_size_override("font_size", 30)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _button_style(Color(0.06, 0.09, 0.14, 0.78)))
	button.add_theme_stylebox_override("pressed", _button_style(Color(0.18, 0.34, 0.58, 0.95)))
	button.focus_mode = Control.FOCUS_NONE
	root.add_child(button)
	button.button_down.connect(func() -> void: Input.action_press(action_name))
	button.button_up.connect(func() -> void: Input.action_release(action_name))

func _button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.75, 0.82, 0.95, 0.7)
	return style

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		_try_enter_vehicle()

	var input_vector := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	)
	if input_vector.length() > 1.0:
		input_vector = input_vector.normalized()

	var camera_forward := -camera.global_basis.z
	camera_forward.y = 0.0
	camera_forward = camera_forward.normalized()
	var camera_right := camera.global_basis.x
	camera_right.y = 0.0
	camera_right = camera_right.normalized()
	var direction := (camera_right * input_vector.x) + (camera_forward * -input_vector.y)
	direction = direction.normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if input_vector.length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 8.0)

	move_and_slide()

func _try_enter_vehicle() -> void:
	var closest_vehicle: Node3D = null
	var closest_distance := 4.0
	for item in get_tree().get_nodes_in_group("vehicles"):
		if item is Node3D:
			var distance := global_position.distance_to(item.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_vehicle = item
	if closest_vehicle != null:
		closest_vehicle.call("enter", self)
		return

	var closest_shop: Node3D = null
	var shop_distance := 5.0
	for item in get_tree().get_nodes_in_group("shops"):
		if item is Node3D:
			var distance := global_position.distance_to(item.global_position)
			if distance < shop_distance:
				shop_distance = distance
				closest_shop = item
	if closest_shop != null:
		closest_shop.call("open_shop", self)
		return

	var closest_civic: Node3D = null
	var civic_distance := 8.0
	for item in get_tree().get_nodes_in_group("civic_buildings"):
		if item is Node3D:
			var distance := global_position.distance_to(item.global_position)
			if distance < civic_distance or item.get("occupant") == self:
				civic_distance = distance
				closest_civic = item
	if closest_civic != null:
		closest_civic.call("interact_with", self)
		return

	var closest_citizen: Node3D = null
	var citizen_distance := 4.5
	for item in get_tree().get_nodes_in_group("citizens"):
		if item is Node3D:
			var distance := global_position.distance_to(item.global_position)
			if distance < citizen_distance:
				citizen_distance = distance
				closest_citizen = item
	if closest_citizen != null:
		closest_citizen.call("interact_with", self)
		return

	var closest_home: Node3D = null
	var home_distance := 5.5
	for item in get_tree().get_nodes_in_group("homes"):
		if item is Node3D:
			var distance := global_position.distance_to(item.global_position)
			if distance < home_distance or item.get("occupant") == self:
				home_distance = distance
				closest_home = item
	if closest_home != null:
		closest_home.call("interact_with", self)

func use_home_object(object_name: String) -> void:
	match object_name:
		"cama":
			energy = minf(100.0, energy + 65.0)
			hunger = maxf(0.0, hunger - 4.0)
			_update_needs_display()
			_save_progress()
			_show_home_feedback("Você descansou. Energia recuperada.")
		"geladeira":
			if money < 10:
				_show_home_feedback("Você precisa de $10 para preparar uma refeição.")
				return
			money -= 10
			hunger = minf(100.0, hunger + 42.0)
			_update_money_display()
			_update_needs_display()
			_save_progress()
			_show_home_feedback("Refeição preparada. Fome recuperada.")
		"chuveiro":
			hygiene = 100.0
			_update_needs_display()
			_save_progress()
			_show_home_feedback("Banho tomado. Higiene restaurada.")

func use_city_service(service: String) -> void:
	match service:
		"restaurant":
			if money < 15:
				_show_city_feedback("Você precisa de $15 para comprar uma refeição.")
				return
			money -= 15
			hunger = minf(100.0, hunger + 45.0)
			_update_money_display()
			_show_city_feedback("Refeição comprada! Sua fome melhorou.")
		"hospital":
			energy = minf(100.0, energy + 35.0)
			hygiene = minf(100.0, hygiene + 10.0)
			_show_city_feedback("Atendimento concluído. Você recuperou energia.")
		"school":
			energy = maxf(0.0, energy - 8.0)
			study_points += 1
			_show_city_feedback("Aula concluída! Estudos: " + str(study_points) + " aulas.")
		"mall":
			if money < 50:
				_show_city_feedback("Junte $50 para comprar uma roupa nova.")
				return
			money -= 50
			outfit_material.albedo_color = Color(randf_range(0.15, 0.8), randf_range(0.15, 0.8), randf_range(0.15, 0.8))
			_update_money_display()
			_show_city_feedback("Roupa nova comprada por $50!")
	_update_needs_display()
	_save_progress()

func _show_city_feedback(message: String) -> void:
	for building in get_tree().get_nodes_in_group("civic_buildings"):
		if building.get("occupant") == self:
			building.call("_message", message)
			return

func _show_home_feedback(message: String) -> void:
	var home := get_tree().get_first_node_in_group("homes")
	if home != null:
		home.call("_show_message", message)

func buy_outfit(price: int) -> bool:
	if money < price:
		return false
	money -= price
	outfit_material.albedo_color = Color(0.12, 0.42, 0.28)
	_save_progress()
	return true
