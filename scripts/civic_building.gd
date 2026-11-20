extends Node3D

@export var building_type: String = "restaurant"
@export var display_name: String = "Estabelecimento"
@export var interior_origin := Vector3(130.0, 0.0, 130.0)

var occupant: Node3D
var inside := false

func _ready() -> void:
	add_to_group("civic_buildings")
	_build_room()

func interact_with(player: Node3D) -> void:
	if occupant != null and occupant != player:
		return
	if occupant == player:
		var local_pos: Vector3 = player.global_position - interior_origin
		if local_pos.z > 3.8 and absf(local_pos.x) < 2.5:
			player.global_position = global_position + Vector3(0.0, 1.2, 9.0)
			occupant = null
			inside = false
			_message("Você saiu de " + display_name + ".")
		else:
			player.call("use_city_service", building_type)
	else:
		occupant = player
		inside = true
		player.global_position = interior_origin + Vector3(0.0, 1.2, 2.4)
		player.set("velocity", Vector3.ZERO)
		_message("Você entrou em " + display_name + ". AÇÃO no balcão para usar o serviço; perto da porta para sair.")

func _message(value: String) -> void:
	var label := Label3D.new()
	label.text = value
	label.top_level = true
	label.global_position = interior_origin + Vector3(0, 4.0, 0)
	label.font_size = 26
	label.modulate = Color(1.0, 0.88, 0.58)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)
	get_tree().create_timer(3.5).timeout.connect(func() -> void:
		if is_instance_valid(label):
			label.queue_free()
	)

func _build_room() -> void:
	_box("Piso", Vector3(0, 0.0, 0), Vector3(12, 0.25, 10), Color(0.48, 0.47, 0.43))
	_box("Parede fundo", Vector3(0, 1.7, -5), Vector3(12, 3.4, 0.25), Color(0.78, 0.77, 0.70))
	_box("Parede esquerda", Vector3(-6, 1.7, 0), Vector3(0.25, 3.4, 10), Color(0.78, 0.77, 0.70))
	_box("Parede direita", Vector3(6, 1.7, 0), Vector3(0.25, 3.4, 10), Color(0.78, 0.77, 0.70))
	_box("Parede frontal esquerda", Vector3(-4.8, 1.7, 5), Vector3(2.4, 3.4, 0.25), Color(0.78, 0.77, 0.70))
	_box("Parede frontal direita", Vector3(4.8, 1.7, 5), Vector3(2.4, 3.4, 0.25), Color(0.78, 0.77, 0.70))
	_box("Balcão de atendimento", Vector3(0, 0.65, -2.7), Vector3(5.0, 1.3, 0.9), Color(0.30, 0.22, 0.16))
	_box("Computador", Vector3(0, 1.45, -2.7), Vector3(0.9, 0.45, 0.18), Color(0.10, 0.13, 0.16))
	_box("Banco esquerdo", Vector3(-3.4, 0.45, 1.0), Vector3(1.5, 0.9, 1.0), Color(0.24, 0.32, 0.42))
	_box("Banco direito", Vector3(3.4, 0.45, 1.0), Vector3(1.5, 0.9, 1.0), Color(0.24, 0.32, 0.42))
	var sign := Label3D.new()
	sign.text = display_name.to_upper()
	sign.top_level = true
	sign.global_position = interior_origin + Vector3(0, 3.0, -4.7)
	sign.font_size = 34
	sign.modulate = Color(0.20, 0.24, 0.30)
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(sign)

func _box(label: String, local_pos: Vector3, size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.name = label
	body.top_level = true
	body.global_position = interior_origin + local_pos
	add_child(body)

	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	visual.material_override = material
	body.add_child(visual)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
