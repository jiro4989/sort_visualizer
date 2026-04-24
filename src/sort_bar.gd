class_name SortBar

var value: int
var column: VBoxContainer
var panel: Panel
var panel_style: StyleBoxFlat
var height_tween: Tween
var bar_width: float
var bar_height: float
var enable_animation: bool = false
const HEIGHT_ANIMATION_SEC: float = 0.08

func _init(_value: int, _bar_width: float, _bar_height: float, color: Color) -> void:
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

	panel_style = StyleBoxFlat.new()
	panel_style.bg_color = color
	# panel の角を丸めない
	panel_style.corner_radius_top_left = 0
	panel_style.corner_radius_top_right = 0
	panel_style.corner_radius_bottom_right = 0
	panel_style.corner_radius_bottom_left = 0
	panel.add_theme_stylebox_override("panel", panel_style)

	set_value(value)
	apply_panel_style(color)
	column.add_child(panel)

## Panel の背景色を変更する。
func apply_panel_style(color: Color) -> void:
	if panel_style.bg_color == color:
		return
	panel_style.bg_color = color
	panel.queue_redraw()

func get_value() -> int:
	return value

func set_value(_value: int) -> void:
	value = _value
	var target_size := Vector2(0, _value * bar_height)

	# アニメーション無効時や初期化直後は即時反映する。
	if not enable_animation or not panel.is_inside_tree():
		if is_instance_valid(height_tween):
			height_tween.kill()
		panel.custom_minimum_size = target_size
		return

	if is_instance_valid(height_tween):
		height_tween.kill()

	height_tween = panel.create_tween()
	height_tween.set_trans(Tween.TRANS_SINE)
	height_tween.set_ease(Tween.EASE_OUT)
	height_tween.tween_property(panel, "custom_minimum_size", target_size, HEIGHT_ANIMATION_SEC)

## 値変更時のアニメーションの有効無効を変更する。
func set_enable_animation(enable: bool) -> void:
	enable_animation = enable
