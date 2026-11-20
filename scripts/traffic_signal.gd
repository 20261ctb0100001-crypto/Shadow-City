extends Node3D

var phase_time: float = 0.0
var x_light: MeshInstance3D
var z_light: MeshInstance3D
var x_material: StandardMaterial3D
var z_material: StandardMaterial3D

func _ready() -> void:
	add_to_group("traffic_signals")
	_build_signal()

func _process(delta: float) -> void:
	phase_time = fmod(phase_time + delta, 12.0)
	_update_lights()

func is_axis_green(axis: Vector3) -> bool:
	if absf(axis.x) > 0.5:
		return phase_time < 5.0
	return phase_time >= 7.0

func _build_signal() -> void:
	var pole := MeshInstance3D.new()
	var pole_mesh := CylinderMesh.new()
	pole_mesh.top_radius = 0.10
	pole_mesh.bottom_radius = 0.14
	pole_mesh.height = 4.2
	pole.mesh = pole_mesh
	pole.position = Vector3(-7.0, 2.1, -7.0)
	var pole_material := StandardMaterial3D.new()
	pole_material.albedo_color = Color(0.12, 0.14, 0.16)
	pole.material_override = pole_material
	add_child(pole)

	x_light = _make_lamp(Vector3(-6.65, 4.15, -7.0))
	z_light = _make_lamp(Vector3(-7.0, 4.15, -6.65))
	x_material = x_light.material_override as StandardMaterial3D
	z_material = z_light.material_override as StandardMaterial3D
	_update_lights()

	var label := Label3D.new()
	label.text = "SEMÁFORO"
	label.position = Vector3(-7.0, 4.9, -7.0)
	label.font_size = 25
	label.modulate = Color(1.0, 1.0, 1.0, 0.9)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(label)

func _make_lamp(lamp_position: Vector3) -> MeshInstance3D:
	var lamp := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.22
	sphere.height = 0.44
	lamp.mesh = sphere
	lamp.position = lamp_position
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.emission_enabled = true
	lamp.material_override = material
	add_child(lamp)
	return lamp

func _update_lights() -> void:
	if x_material == null or z_material == null:
		return
	var x_green := phase_time < 5.0
	var z_green := phase_time >= 7.0
	x_material.albedo_color = Color(0.12, 1.0, 0.20) if x_green else Color(1.0, 0.04, 0.02)
	x_material.emission = x_material.albedo_color
	z_material.albedo_color = Color(0.12, 1.0, 0.20) if z_green else Color(1.0, 0.04, 0.02)
	z_material.emission = z_material.albedo_color
