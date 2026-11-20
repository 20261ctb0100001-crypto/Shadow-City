extends Node3D

@export var travel_axis: Vector3 = Vector3.FORWARD
@export var travel_speed: float = 7.0
@export var lane_offset: Vector3 = Vector3.ZERO
@export var route_min: float = -54.0
@export var route_max: float = 54.0
@export var vehicle_color: Color = Color(0.18, 0.42, 0.72)
@export_enum("car", "bus", "motorcycle") var vehicle_type: String = "car"

var route_position: float = 0.0
var signal_controller: Node

func _ready() -> void:
	add_to_group("traffic")
	travel_axis = travel_axis.normalized()
	route_position = global_position.dot(travel_axis)
	rotation.y = atan2(-travel_axis.x, -travel_axis.z)
	_build_vehicle()
	var signals := get_tree().get_nodes_in_group("traffic_signals")
	if not signals.is_empty():
		signal_controller = signals[0]

func _build_vehicle() -> void:
	if vehicle_type == "bus":
		_add_part("Bus body", Vector3(0, 1.35, 0), Vector3(2.35, 2.45, 7.8), vehicle_color)
		_add_part("Bus front glass", Vector3(0, 2.05, -3.94), Vector3(1.85, 1.05, 0.08), Color(0.12, 0.25, 0.32))
		for side in [-1.0, 1.0]:
			for window_z in [-2.6, -1.0, 0.6, 2.2]:
				_add_part("Bus window", Vector3(side * 1.19, 2.0, window_z), Vector3(0.06, 0.92, 1.25), Color(0.15, 0.30, 0.38))
			for axle in [-2.6, 0.0, 2.6]:
				_add_wheel(side * 1.2, 0.48, axle, 0.42)
	elif vehicle_type == "motorcycle":
		_add_part("Motorcycle frame", Vector3(0, 0.88, 0), Vector3(0.42, 0.48, 1.75), vehicle_color)
		_add_part("Motorcycle seat", Vector3(0, 1.18, 0.30), Vector3(0.55, 0.18, 0.75), Color(0.035, 0.04, 0.045))
		_add_part("Motorcycle tank", Vector3(0, 1.25, -0.28), Vector3(0.62, 0.48, 0.72), vehicle_color)
		_add_wheel(0.0, 0.43, -0.85, 0.34)
		_add_wheel(0.0, 0.43, 0.85, 0.34)
	else:
		_add_part("Body", Vector3(0, 0.72, 0), Vector3(1.9, 0.72, 3.8), vehicle_color)
		_add_part("Cabin", Vector3(0, 1.28, -0.25), Vector3(1.48, 0.68, 1.85), Color(0.10, 0.17, 0.22))
		_add_part("Front glass", Vector3(0, 1.34, -1.18), Vector3(1.30, 0.48, 0.06), Color(0.25, 0.43, 0.52))
		_add_part("Rear glass", Vector3(0, 1.34, 0.70), Vector3(1.30, 0.48, 0.06), Color(0.18, 0.29, 0.36))
		for side in [-1.0, 1.0]:
			for axle in [-1.15, 1.15]:
				_add_wheel(side * 0.98, 0.34, axle, 0.32)

func _add_wheel(x: float, y: float, z: float, radius: float) -> void:
	var wheel := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.18
	wheel.mesh = mesh
	wheel.rotation_degrees.z = 90
	wheel.position = Vector3(x, y, z)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.025, 0.03, 0.035)
	wheel.material_override = material
	add_child(wheel)

func _add_part(part_name: String, part_position: Vector3, dimensions: Vector3, color: Color) -> void:
	var part := MeshInstance3D.new()
	part.name = part_name
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	part.mesh = mesh
	part.position = part_position
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.38
	part.material_override = material
	add_child(part)

func _process(delta: float) -> void:
	var stopped_at_red := false
	if is_instance_valid(signal_controller) and absf(route_position) <= 7.0:
		var green: bool = signal_controller.call("is_axis_green", travel_axis)
		if not green:
			if travel_axis.dot(Vector3.RIGHT) > 0.5:
				stopped_at_red = route_position >= -7.0 and route_position < 0.0
			elif travel_axis.dot(Vector3.RIGHT) < -0.5:
				stopped_at_red = route_position <= 7.0 and route_position > 0.0
			elif travel_axis.dot(Vector3.BACK) > 0.5:
				stopped_at_red = route_position >= -7.0 and route_position < 0.0
			else:
				stopped_at_red = route_position <= 7.0 and route_position > 0.0
	if not stopped_at_red:
		route_position += travel_speed * delta
	if route_position > route_max:
		route_position = route_min
	elif route_position < route_min:
		route_position = route_max
	global_position = lane_offset + travel_axis * route_position
