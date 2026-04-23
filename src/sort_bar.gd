class_name SortBar

const BAR_DEFAULT_COLOR: Color = Color(0.25, 0.6, 0.95, 1.0)
const BAR_SELECTED_COLOR: Color = Color(1.0, 0.25, 0.25, 1.0)

var value: int
var column: VBoxContainer
var panel: Panel
var bar_width: int
var bar_height: int

func _init(_value: int, _bar_width: int, _bar_height: int) -> void:
	value = _value
	bar_width = _bar_width
	bar_height = _bar_height

	column = VBoxContainer.new()
	column.custom_minimum_size = Vector2(bar_width, 0)
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# 上側の余白を可変にして、バーを下寄せにする
	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)

	panel = Panel.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	set_value(value)
	apply_panel_style(BAR_DEFAULT_COLOR)
	column.add_child(panel)

## Panel の背景色を変更する。
func apply_panel_style(color: Color) -> void:
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = color
	# panel の角を丸めない
	style_box.corner_radius_top_left = 0
	style_box.corner_radius_top_right = 0
	style_box.corner_radius_bottom_right = 0
	style_box.corner_radius_bottom_left = 0
	panel.add_theme_stylebox_override("panel", style_box)

func get_value() -> int:
	return value

func set_value(_value: int) -> void:
	value = _value
	panel.custom_minimum_size = Vector2(0, _value * bar_height)
