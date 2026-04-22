extends Node2D

@onready var select_sort_option: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer/SelectSortOption
@onready var sort_visualization_area: HBoxContainer = $MarginContainer/VBoxContainer/SortVisualizationArea

const MAX_SIZE: int = 100
const MARGIN_SIZE: int = 6
const BUTTON_HEIGHT: int = 31
const VISUALIZATION_AREA_WIDTH: int = 1600 - MARGIN_SIZE * 2
const VISUALIZATION_AREA_HEIGHT: int = 900 - BUTTON_HEIGHT - MARGIN_SIZE * 2
const BAR_WIDTH: int = floori(float(VISUALIZATION_AREA_WIDTH) / MAX_SIZE)
const BAR_HEIGHT: int = floori(float(VISUALIZATION_AREA_HEIGHT) / MAX_SIZE)
var sort_values: Array[int] = []
var panels: Array[Panel] = []

func _ready() -> void:
	# 可視化エリアの初期化
	for i in range(MAX_SIZE):
		sort_values.append(i+1)
	sort_values.shuffle()

	# Panel を生成して MAX_SIZE 分だけ生成する
	for i in sort_values:
		var width: int = BAR_WIDTH
		var height: int = BAR_HEIGHT * i
		var column: VBoxContainer = VBoxContainer.new()
		column.custom_minimum_size = Vector2(width, 0)
		column.size_flags_vertical = Control.SIZE_EXPAND_FILL

		# 上側の余白を可変にして、バーを下寄せにする
		var spacer: Control = Control.new()
		spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
		column.add_child(spacer)

		var panel: Panel = Panel.new()
		panel.custom_minimum_size = Vector2(0, height)
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# panel の角を丸めない
		var style_box := StyleBoxFlat.new()
		style_box.corner_radius_top_left = 0
		style_box.corner_radius_top_right = 0
		style_box.corner_radius_bottom_right = 0
		style_box.corner_radius_bottom_left = 0
		panel.add_theme_stylebox_override("panel", style_box)

		column.add_child(panel)
		panels.append(panel)
		sort_visualization_area.add_child(column)

func _on_shuffle_button_pressed() -> void:
	sort_values.shuffle()
	for i in range(MAX_SIZE):
		panels[i].custom_minimum_size = Vector2(0, BAR_HEIGHT * sort_values[i])

func _on_run_sort_button_pressed() -> void:
	pass # Replace with function body.
