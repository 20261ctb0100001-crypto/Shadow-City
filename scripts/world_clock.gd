extends Node

@export var day_length_seconds: float = 600.0
@export_range(0.0, 24.0) var starting_hour: float = 8.0

var time_of_day: float
var sun: DirectionalLight3D
var world_environment: WorldEnvironment
var clock_label: Label

func _ready() -> void:
	time_of_day = starting_hour
	sun = get_tree().current_scene.find_child("*", true, false) as DirectionalLight3D
	world_environment = get_tree().current_scene.find_child("*", true, false) as WorldEnvironment
	_create_clock_display()
	_update_world()

func _process(delta: float) -> void:
	time_of_day = fmod(time_of_day + (24.0 / maxf(day_length_seconds, 1.0)) * delta, 24.0)
	_update_world()

func _create_clock_display() -> void:
	var layer := CanvasLayer.new()
	layer.name = "WorldClockHUD"
	get_tree().root.add_child.call_deferred(layer)

	clock_label = Label.new()
	clock_label.position = Vector2(18, 18)
	clock_label.add_theme_font_size_override("font_size", 24)
	clock_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	clock_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.9))
	clock_label.add_theme_constant_override("shadow_offset_x", 2)
	clock_label.add_theme_constant_override("shadow_offset_y", 2)
	layer.add_child(clock_label)

func _update_world() -> void:
	var hour_angle := (time_of_day / 24.0) * TAU
	var daylight := clampf(sin(hour_angle - PI * 0.5) * 1.8 + 0.15, 0.08, 1.0)
	if sun != null:
		sun.rotation_degrees.x = (time_of_day / 24.0) * 360.0 - 90.0
		sun.light_energy = daylight * 1.25
		sun.light_color = Color(1.0, 0.78, 0.58).lerp(Color(1.0, 1.0, 0.94), daylight)
	if world_environment != null and world_environment.environment != null:
		world_environment.environment.ambient_light_energy = 0.12 + daylight * 0.58
	if clock_label != null:
		var hour := int(floor(time_of_day))
		var minute := int(floor((time_of_day - float(hour)) * 60.0))
		var period := "Noite"
		if hour >= 5 and hour < 12:
			period = "Manhã"
		elif hour >= 12 and hour < 18:
			period = "Tarde"
		elif hour >= 18 and hour < 20:
			period = "Entardecer"
		clock_label.text = "%02d:%02d  •  %s" % [hour, minute, period]
