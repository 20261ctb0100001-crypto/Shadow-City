extends CharacterBody3D

@export var display_name: String = "Morador"
@export var profession: String = "Comerciante"
@export var personality: String = "Calmo e observador"
@export var dialogue: String = "Olá! Como está?"
@export var shift_reward: int = 75
@export var walk_speed: float = 1.2
@export var favorite_color: Color = Color(0.3, 0.5, 0.8)

var home_position := Vector3.ZERO
var work_position := Vector3.ZERO
var leisure_position := Vector3.ZERO
var routine_target := Vector3.ZERO
var routine_state := "Casa"
var routine_refresh := 0.0
var world_clock: Node
var name_label: Label3D
var direction := Vector3.ZERO
var decision_time := 0.0
var menu_layer: CanvasLayer
var working := false
var mission_active := false
var mission_target := Vector3.ZERO
var mission_marker: Node3D
var mission_status: Label
var mission_hud_layer: CanvasLayer
var active_player: Node

func _ready() -> void:
	add_to_group("citizens")
	home_position = global_position
	routine_target = home_position
	work_position = home_position + Vector3(5, 0, 0)
	leisure_position = home_position + Vector3(0, 0, 7)
	world_clock = get_tree().current_scene.find_child("WorldClock", true, false)
	_build_person()
	_choose_direction()

func _build_person() -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = favorite_color
	material.roughness = 0.82
	var body := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.34
	capsule.height = 1.7
	body.mesh = capsule
	body.position.y = 0.85
	body.material_override = material
	add_child(body)

	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.28
	head_mesh.height = 0.56
	head.mesh = head_mesh
	head.position.y = 1.83
	var skin := StandardMaterial3D.new()
	skin.albedo_color = Color(0.72, 0.52, 0.39)
	head.material_override = skin
	add_child(head)

	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.34
	shape.height = 1.7
	collision.shape = shape
	collision.position.y = 0.85
	add_child(collision)

	name_label = Label3D.new()
	name_label.text = display_name + " • " + profession
	name_label.position.y = 2.35
	name_label.font_size = 25
	name_label.modulate = Color(1, 1, 1, 0.9)
	name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(name_label)

func _choose_direction() -> void:
	_choose_local_direction()

func _physics_process(delta: float) -> void:
	if working or menu_layer != null:
		_stop_horizontal(delta)
		move_and_slide()
		return

	routine_refresh -= delta
	if routine_refresh <= 0.0:
		_update_daily_routine()
		routine_refresh = 4.0

	var offset := routine_target - global_position
	offset.y = 0.0
	if offset.length() > 2.0:
		direction = offset.normalized()
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
	else:
		decision_time -= delta
		if decision_time <= 0.0:
			_choose_local_direction()
		velocity.x = direction.x * walk_speed * 0.35
		velocity.z = direction.z * walk_speed * 0.35

	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	if Vector2(velocity.x, velocity.z).length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 3.0)

func _stop_horizontal(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, 5.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, 5.0 * delta)

func _update_daily_routine() -> void:
	if world_clock == null or not is_instance_valid(world_clock):
		return
	var hour := float(world_clock.get("time_of_day"))
	var next_state := "Casa"
	var next_target := home_position
	if hour >= 8.0 and hour < 17.0:
		next_state = "Trabalhando"
		next_target = work_position
	elif hour >= 17.0 and hour < 21.0:
		next_state = "Lazer"
		next_target = leisure_position
	if next_state != routine_state:
		routine_state = next_state
		routine_target = next_target
		if is_instance_valid(name_label):
			name_label.text = display_name + " • " + profession + " • " + routine_state

func _choose_local_direction() -> void:
	var angle := randf_range(0.0, TAU)
	direction = Vector3(cos(angle), 0, sin(angle))
	decision_time = randf_range(1.5, 3.5)

func _process(_delta: float) -> void:
	if not mission_active or not is_instance_valid(active_player):
		return
	var distance := Vector2(active_player.global_position.x - mission_target.x, active_player.global_position.z - mission_target.z).length()
	if is_instance_valid(mission_status):
		mission_status.text = "Vá até o marcador dourado. Distância: " + str(roundi(distance)) + " m"
	if distance <= 2.4:
		_complete_mission()

func interact_with(player: Node) -> void:
	if menu_layer != null or mission_active:
		return
	_open_dialogue(player)

func _open_dialogue(player: Node) -> void:
	menu_layer = CanvasLayer.new()
	menu_layer.name = "CitizenDialogue"
	get_tree().root.add_child(menu_layer)
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.01, 0.02, 0.04, 0.78)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_layer.add_child(backdrop)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_layer.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(440, 330)
	center.add_child(panel)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 12)
	panel.add_child(layout)

	var title := Label.new()
	title.text = display_name + " — " + profession
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	layout.add_child(title)
	var personality_label := Label.new()
	personality_label.text = "Personalidade: " + personality
	personality_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(personality_label)
	var speech := Label.new()
	speech.text = dialogue
	speech.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	speech.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(speech)
	var status := Label.new()
	status.text = "Trabalho disponível: " + profession + " • Pagamento: $" + str(shift_reward)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(status)

	var work_button := Button.new()
	work_button.text = "Aceitar trabalho (+$" + str(shift_reward) + ")"
	work_button.custom_minimum_size = Vector2(0, 54)
	layout.add_child(work_button)
	work_button.pressed.connect(func() -> void:
		if working or not is_instance_valid(player):
			return
		_start_mission(player, status, work_button)
	)
	var close_button := Button.new()
	close_button.text = "Fechar conversa"
	close_button.custom_minimum_size = Vector2(0, 44)
	layout.add_child(close_button)
	close_button.pressed.connect(_close_dialogue)

func _start_mission(player: Node, status: Label, work_button: Button) -> void:
	working = true
	mission_active = true
	active_player = player
	work_button.disabled = true
	work_button.text = "Trabalho em andamento"
	var offset := Vector3(0, 0, -14)
	mission_target = player.global_position + offset
	mission_target.y = 0.12
	_create_mission_marker()
	_close_dialogue()
	_create_mission_hud()

func _create_mission_hud() -> void:
	mission_hud_layer = CanvasLayer.new()
	mission_hud_layer.name = "JobMissionHUD"
	get_tree().root.add_child(mission_hud_layer)
	mission_status = Label.new()
	mission_status.position = Vector2(18, 58)
	mission_status.add_theme_font_size_override("font_size", 22)
	mission_status.add_theme_color_override("font_color", Color(1.0, 0.86, 0.42))
	mission_status.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	mission_status.add_theme_constant_override("shadow_offset_x", 2)
	mission_status.add_theme_constant_override("shadow_offset_y", 2)
	mission_status.text = "Trabalho: siga o marcador dourado."
	mission_hud_layer.add_child(mission_status)

func _create_mission_marker() -> void:
	mission_marker = Node3D.new()
	mission_marker.name = "JobDestination"
	mission_marker.position = mission_target
	get_tree().current_scene.add_child(mission_marker)

	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 1.15
	torus.outer_radius = 1.55
	ring.mesh = torus
	var ring_material := StandardMaterial3D.new()
	ring_material.albedo_color = Color(1.0, 0.72, 0.12)
	ring_material.emission_enabled = true
	ring_material.emission = Color(1.0, 0.48, 0.04)
	ring.material_override = ring_material
	ring.rotation_degrees.x = 90
	mission_marker.add_child(ring)

	var beam := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 0.08
	cylinder.bottom_radius = 0.08
	cylinder.height = 3.2
	beam.mesh = cylinder
	beam.position.y = 1.8
	var beam_material := StandardMaterial3D.new()
	beam_material.albedo_color = Color(1.0, 0.78, 0.22, 0.65)
	beam_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_material.emission_enabled = true
	beam_material.emission = Color(1.0, 0.55, 0.08)
	beam.material_override = beam_material
	mission_marker.add_child(beam)

	var marker_label := Label3D.new()
	marker_label.text = "DESTINO DO TRABALHO"
	marker_label.position.y = 3.8
	marker_label.font_size = 32
	marker_label.modulate = Color(1.0, 0.86, 0.42)
	marker_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	mission_marker.add_child(marker_label)

func _complete_mission() -> void:
	mission_active = false
	working = false
	if is_instance_valid(active_player):
		active_player.call("add_money", shift_reward)
	if is_instance_valid(mission_status):
		mission_status.text = "Trabalho concluído! +$" + str(shift_reward)
	if is_instance_valid(mission_hud_layer):
		var clear_timer := Timer.new()
		mission_hud_layer.add_child(clear_timer)
		clear_timer.one_shot = true
		clear_timer.wait_time = 4.0
		clear_timer.timeout.connect(func() -> void:
			if is_instance_valid(mission_hud_layer):
				mission_hud_layer.queue_free()
			mission_hud_layer = null
			mission_status = null
		)
		clear_timer.start()
	if is_instance_valid(mission_marker):
		mission_marker.queue_free()
	active_player = null
	mission_marker = null

func _close_dialogue() -> void:
	if menu_layer != null:
		menu_layer.queue_free()
		menu_layer = null
