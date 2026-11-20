extends Node3D

var occupant: Node3D
var is_occupied := false
var interior_origin := Vector3(120.0, 0.0, 120.0)

func _ready() -> void:
	add_to_group("homes")
	_build_interior()

func interact_with(player: Node3D) -> void:
	if is_occupied and occupant != player:
		return
	if occupant == player:
		player.global_position = Vector3(19.0, 1.2, 10.5)
		occupant = null
		is_occupied = false
		player.set("velocity", Vector3.ZERO)
		_show_message("Você saiu de casa.")
	else:
		occupant = player
		is_occupied = true
		player.global_position = interior_origin + Vector3(0.0, 1.2, 2.5)
		player.set("velocity", Vector3.ZERO)
		_show_message("Casa inicial: AÇÃO para sair. VIDA para cuidar das necessidades.")

func _show_message(message: String) -> void:
	var hint := Label3D.new()
	hint.text = message
	hint.position = interior_origin + Vector3(0.0, 3.5, 0.0)
	hint.font_size = 30
	hint.modulate = Color(1.0, 0.88, 0.58)
	hint.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(hint)
	get_tree().create_timer(3.0).timeout.connect(func() -> void:
		if is_instance_valid(hint):
			hint.queue_free()
	)

func _build_interior() -> void:
	_add_box("Piso da casa", Vector3(0, 0.0, 0), Vector3(12, 0.25, 10), Color(0.38, 0.25, 0.16))
	_add_box("Parede do fundo", Vector3(0, 1.6, -5), Vector3(12, 3.2, 0.25), Color(0.76, 0.69, 0.57))
	_add_box("Parede esquerda", Vector3(-6, 1.6, 0), Vector3(0.25, 3.2, 10), Color(0.76, 0.69, 0.57))
	_add_box("Parede direita", Vector3(6, 1.6, 0), Vector3(0.25, 3.2, 10), Color(0.76, 0.69, 0.57))
	_add_box("Parede frontal esquerda", Vector3(-4.8, 1.6, 5), Vector3(2.4, 3.2, 0.25), Color(0.76, 0.69, 0.57))
	_add_box("Parede frontal direita", Vector3(4.8, 1.6, 5), Vector3(2.4, 3.2, 0.25), Color(0.76, 0.69, 0.57))
	_add_box("Cama", Vector3(-3.5, 0.55, -2.5), Vector3(3.0, 0.7, 4.0), Color(0.25, 0.34, 0.55))
	_add_box("Travesseiro", Vector3(-3.5, 0.98, -4.0), Vector3(1.8, 0.2, 0.8), Color(0.88, 0.87, 0.78))
	_add_box("Sofá", Vector3(2.7, 0.55, -2.4), Vector3(3.2, 1.0, 1.3), Color(0.30, 0.22, 0.18))
	_add_box("Mesa", Vector3(2.5, 0.55, 1.0), Vector3(2.2, 0.15, 1.5), Color(0.34, 0.20, 0.11))
	_add_box("Pé da mesa", Vector3(2.5, 0.25, 1.0), Vector3(0.18, 0.6, 0.18), Color(0.22, 0.14, 0.08))
	_add_box("Balcão da cozinha", Vector3(-3.8, 0.65, 2.0), Vector3(2.6, 1.3, 1.0), Color(0.48, 0.48, 0.45))
	_add_box("Geladeira", Vector3(-4.5, 1.1, 3.8), Vector3(1.1, 2.2, 1.0), Color(0.72, 0.76, 0.78))
	_add_box("Box do banheiro", Vector3(4.5, 1.2, 3.5), Vector3(1.8, 2.4, 2.0), Color(0.48, 0.65, 0.70))
	_add_box("Tapete", Vector3(0, 0.14, 0.0), Vector3(3.0, 0.04, 2.0), Color(0.58, 0.28, 0.18))
	_add_box("Luminária", Vector3(0, 3.0, 0), Vector3(0.8, 0.12, 0.8), Color(1.0, 0.84, 0.52))
	var title := Label3D.new()
	title.text = "MINHA CASA"
	title.position = interior_origin + Vector3(0, 3.3, -4.7)
	title.font_size = 34
	title.modulate = Color(0.25, 0.20, 0.14)
	title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(title)

func _add_box(label: String, local_position: Vector3, dimensions: Vector3, color: Color) -> void:
	var visual := MeshInstance3D.new()
	visual.name = label
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	visual.mesh = mesh
	visual.position = interior_origin + local_position
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	visual.material_override = material
	add_child(visual)
