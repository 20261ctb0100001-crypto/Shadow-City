extends Node3D

@export var travel_axis: Vector3 = Vector3.FORWARD
@export var travel_speed: float = 7.0
@export var lane_offset: Vector3 = Vector3.ZERO
@export var route_min: float = -54.0
@export var route_max: float = 54.0
@export var vehicle_color: Color = Color(0.18, 0.42, 0.72)

var route_position: float = 0.0

func _ready() -> void:
	add_to_group("traffic")
	travel_axis = travel_axis.normalized()
	route_position = global_position.dot(travel_axis)
	rotation.y = atan2(-travel_axis.x, -travel_axis.z)
	_build_vehicle()

func _build_vehicle() -> void:
	_add_part("Body", Vector3(0, 0.72, 0), Vector3(1.9, 0.72, 3.8), vehicle_color)
	_add_part("Cabin", Vector3(0, 1.28, -0.25), Vector3(1.48, 0.68, 1.85), Color(0.10, 0.17, 0.22))
	_add_part("Front glass", Vector3(0, 1.34, -1.18), Vector3(1.30, 0.48, 0.06), Color(0.25, 0.43, 0.52))
	_add_part("Rear glass", Vector3(0, 1.34, 0.70), Vector3(1.30, 0.48, 0.06), Color(0.18, 0.29, 0.36))
	for side in [-1.0, 1.0]:
		for axle in [-1.15, 1.15]:
			var wheel := MeshInstance3D.new()
			var mesh := CylinderMesh.new()
			mesh.top_radius = 0.32
			mesh.bottom_radius = 0.32
			mesh.height = 0.18
			wheel.mesh = mesh
			wheel.rotation_degrees.z = 90
			wheel.position = Vector3(side * 0.98, 0.34, axle)
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
	route_position += travel_speed * delta
	if route_position > route_max:
		route_position = route_min
	elif route_position < route_min:
		route_position = route_max
	global_position = lane_offset + travel_axis * route_position
