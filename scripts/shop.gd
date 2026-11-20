extends Node3D

var menu_layer: CanvasLayer
var status_label: Label

func _ready() -> void:
	add_to_group("shops")

func open_shop(player: CharacterBody3D) -> void:
	if menu_layer != null:
		return

	menu_layer = CanvasLayer.new()
	menu_layer.name = "ClothingShopMenu"
	get_tree().root.add_child(menu_layer)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.015, 0.025, 0.04, 0.78)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_layer.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_layer.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 300)
	center.add_child(panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	panel.add_child(layout)

	var title := Label.new()
	title.text = "LOJA DE ROUPAS"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 26)
	layout.add_child(title)

	var description := Label.new()
	description.text = "Escolha uma peça para mudar seu visual."
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(description)

	status_label = Label.new()
	status_label.text = "Saldo: $%d" % int(player.get("money"))
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	layout.add_child(status_label)

	var buy_button := Button.new()
	buy_button.text = "Comprar jaqueta urbana  •  $50"
	buy_button.custom_minimum_size = Vector2(0, 54)
	layout.add_child(buy_button)
	buy_button.pressed.connect(func() -> void:
		var success: bool = player.call("buy_outfit", 50)
		if success:
			status_label.text = "Comprado! Saldo: $%d" % int(player.get("money"))
		else:
			status_label.text = "Dinheiro insuficiente. Saldo: $%d" % int(player.get("money"))
	)

	var close_button := Button.new()
	close_button.text = "Fechar loja"
	close_button.custom_minimum_size = Vector2(0, 46)
	layout.add_child(close_button)
	close_button.pressed.connect(_close_shop)

func _close_shop() -> void:
	if menu_layer != null:
		menu_layer.queue_free()
		menu_layer = null
