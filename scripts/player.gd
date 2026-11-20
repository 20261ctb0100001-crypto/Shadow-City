extends CharacterBody3D

@export var move_speed: float = 5.5
@export var gravity: float = 9.8

var camera: Camera3D
var mobile_actions: Array[String] = ["move_forward", "move_backward", "move_left", "move_right"]

func _ready() -> void:
	_create_placeholder_character()
	_create_camera()
	_create_mobile_controls()

func _create_placeholder_character() -> void:
	var visual := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.38
	capsule.height = 1.75
	visual.mesh = capsule
	visual.position.y = 0.88
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.16, 0.30, 0.58)
	material.roughness = 0.78
	visual.material_override = material
	add_child(visual)

	var collision := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.38
	shape.height = 1.75
	collision.shape = shape
	collision.position.y = 0.88
	add_child(collision)

func _create_camera() -> void:
	var pivot := Node3D.new()
	pivot.name = "CameraPivot"
	pivot.position.y = 1.45
	add_child(pivot)

	camera = Camera3D.new()
	camera.position = Vector3(0, 2.1, 6.0)
	camera.rotation_degrees.x = -16.0
	camera.fov = 72.0
	pivot.add_child(camera)
	camera.current = true

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

	var hint := Label.new()
	hint.text = "SHADOW CITY  •  TEST BUILD"
	hint.position = Vector2(18, 16)
	hint.add_theme_font_size_override("font_size", 18)
	hint.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 0.9))
	root.add_child(hint)

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
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	if input_vector.length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * 8.0)

	move_and_slide()
