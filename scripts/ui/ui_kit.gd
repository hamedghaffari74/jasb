class_name UiKit
extends RefCounted
## Shared controls and the industrial UI look (no theme file required).


static func label(text: String, font_size: int, color: Color) -> Label:
	var node := Label.new()
	node.text = text
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	node.text_direction = Control.TEXT_DIRECTION_RTL if I18n.is_fa() else Control.TEXT_DIRECTION_AUTO
	node.add_theme_font_size_override("font_size", font_size)
	node.add_theme_color_override("font_color", color)
	node.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.35))
	node.add_theme_constant_override("shadow_offset_x", 0)
	node.add_theme_constant_override("shadow_offset_y", 2)
	return node


static func button(text: String, accent: Color = Palette.PANEL_LIGHT) -> Button:
	var node := Button.new()
	node.text = text
	node.custom_minimum_size = Vector2(440, 78)
	node.text_direction = Control.TEXT_DIRECTION_RTL if I18n.is_fa() else Control.TEXT_DIRECTION_AUTO
	node.add_theme_font_size_override("font_size", 27)
	node.add_theme_color_override("font_color", Palette.TEXT)
	node.add_theme_color_override("font_hover_color", Palette.TEXT)
	node.add_theme_color_override("font_pressed_color", Palette.TEXT)
	node.add_theme_color_override("font_focus_color", Palette.TEXT)
	node.add_theme_color_override("font_disabled_color", Palette.MUTED)
	node.add_theme_stylebox_override("normal", _box(accent))
	node.add_theme_stylebox_override("hover", _box(accent.lightened(0.16)))
	node.add_theme_stylebox_override("pressed", _box(accent.darkened(0.22)))
	node.add_theme_stylebox_override("disabled", _box(Palette.LOCKED))
	node.add_theme_stylebox_override("focus", _focus_box())
	node.pressed.connect(AudioManager.play.bind("click"))
	return node


static func add_button(parent: Control, text: String, action: Callable, accent: Color = Palette.PANEL_LIGHT) -> Button:
	var node: Button = button(text, accent)
	node.pressed.connect(action)
	parent.add_child(node)
	return node


static func add_background(parent: Control, color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(rect)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return rect


static func add_dim(parent: Control) -> ColorRect:
	var rect: ColorRect = add_background(parent, Color(0.01, 0.03, 0.07, 0.72))
	rect.mouse_filter = Control.MOUSE_FILTER_STOP
	return rect


static func column(parent: Control) -> VBoxContainer:
	var center := CenterContainer.new()
	parent.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 18)
	center.add_child(box)
	return box


static func panel_in_center(parent: Control) -> VBoxContainer:
	var center := CenterContainer.new()
	parent.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	var style: StyleBoxFlat = _box(Palette.PANEL)
	style.set_content_margin_all(30.0)
	style.set_border_width_all(2)
	style.border_color = Palette.PANEL_HIGH
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 16)
	panel.add_child(box)
	return box


static func _box(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(18)
	style.shadow_color = Palette.SHADOW
	style.shadow_size = 10
	style.shadow_offset = Vector2(0, 5)
	style.set_border_width_all(2)
	style.border_color = color.lightened(0.18)
	return style


static func _focus_box() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.draw_center = false
	style.set_border_width_all(3)
	style.border_color = Palette.WARN
	style.set_corner_radius_all(18)
	return style
