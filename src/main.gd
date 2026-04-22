extends Node2D

@onready var select_sort_option: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer/SelectSortOption
@onready var sort_visualization_area: HBoxContainer = $MarginContainer/VBoxContainer/SortVisualizationArea

const MAX_SIZE: int = 100
const MARGIN_SIZE: int = 6
const BUTTON_HEIGHT: int = 31
const VISUALIZATION_AREA_WIDTH: int = 1600 - MARGIN_SIZE * 2
const VISUALIZATION_AREA_HEIGHT: int = 900 - BUTTON_HEIGHT - MARGIN_SIZE * 2
var sort_values: Array[int] = []

func _ready() -> void:
	# 可視化エリアの初期化
	for i in range(MAX_SIZE):
		sort_values.append(i+1)
	sort_values.shuffle()

	# Panel を生成して MAX_SIZE 分だけ生成する
	for i in range(MAX_SIZE):
		var panel: Panel = Panel.new()
		var width: int = floori(float(VISUALIZATION_AREA_WIDTH) / MAX_SIZE)
		var height: int = floori(float(VISUALIZATION_AREA_HEIGHT) / MAX_SIZE) * (i + 1)
		panel.custom_minimum_size = Vector2(width, height)

		# panel の角を丸めない
		var style_box := StyleBoxFlat.new()
		style_box.corner_radius_top_left = 0
		style_box.corner_radius_top_right = 0
		style_box.corner_radius_bottom_right = 0
		style_box.corner_radius_bottom_left = 0
		panel.add_theme_stylebox_override("panel", style_box)

		sort_visualization_area.add_child(panel)

func _on_shuffle_button_pressed() -> void:
	sort_values.shuffle()

func _on_run_sort_button_pressed() -> void:
	pass # Replace with function body.
