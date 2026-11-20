extends CharacterBody3D

@export var display_name: String = "Morador"
@export var profession: String = "Comerciante"
@export var personality: String = "Calmo e observador"
@export var dialogue: String = "Olá! Como está?"
@export var shift_reward: int = 75
@export var walk_speed: float = 1.2
@export var favorite_color: Color = Color(0.3, 0.5, 0.8)

var home_position := Vector3.ZERO
var direction := Vector3.ZERO
var decision_time := 0.0
var menu_layer: CanvasLayer
var working := false

func _ready() -> void:
	add_to_group("citizens")
	home_position = global_position
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

	var label := Label3D.new()
	label.text = display_name + " • " + profession
	label.position.y = 2.35
	label.font_size = 25
	label.modulate = Color(1, 1, 1, 0.9)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)

func _choose_direction() -> void:
	var angle := randf_range(0.0, TAU)
	direction = Vector3(cos(angle), 0, sin(angle))
	decision_time = randf_range(2.0, 5.0)

func _physics_process(delta: float) -> void:
	if working or menu_layer != null:
		velocity.x = move_toward(velocity.x, 0.0, 5.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 5.0 * delta)
		move_and_slide()
		return
	decision_time -= delta
	if decision_time <= 0.0 or global_position.distance_to(home_position) > 10.0:
		_choose_direction()
	velocity.x = direction.x * walk_speed
	velocity.z = direction.z * walk_speed
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0.0
	move_and_slide()
	if Vector2(velocity.x, velocity.z).length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 3.0)

func interact_with(player: Node) -> void:
	if menu_layer != null:
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
	panel.custom_minimum_size = Vector2(440, 310)
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
	status.text = "Vaga disponível: turno de " + profession + " • $" + str(shift_reward)
	status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(status)

	var work_button := Button.new()
	work_button.text = "Fazer turno (+$" + str(shift_reward) + ")"
	work_button.custom_minimum_size = Vector2(0, 54)
	layout.add_child(work_button)
	work_button.pressed.connect(func() -> void:
		if working:
			return
		working = true
		work_button.disabled = true
		work_button.text = "Trabalhando... aguarde"
		status.text = "Você está cumprindo seu turno."
		var shift_timer := Timer.new()
		shift_timer.one_shot = true
		shift_timer.wait_time = 8.0
		add_child(shift_timer)
		shift_timer.timeout.connect(func() -> void:
			if is_instance_valid(player):
				player.call("add_money", shift_reward)
			status.text = "Turno concluído! Você recebeu $" + str(shift_reward) + "."
			work_button.text = "Pagamento recebido"
			working = false
			shift_timer.queue_free()
		)
		shift_timer.start()
	)
	var close_button := Button.new()
	close_button.text = "Fechar conversa"
	close_button.custom_minimum_size = Vector2(0, 44)
	layout.add_child(close_button)
	close_button.pressed.connect(_close_dialogue)

func _close_dialogue() -> void:
	if menu_layer != null:
		menu_layer.queue_free()
		menu_layer = null
