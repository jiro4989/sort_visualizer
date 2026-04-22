extends Node2D

@onready var select_sort_option: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer/SelectSortOption
@onready var sort_visualization_area: HBoxContainer = $MarginContainer/VBoxContainer/SortVisualizationArea
@onready var status_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/StatusLabel

const MAX_SIZE: int = 100
const MARGIN_SIZE: int = 6
const BUTTON_HEIGHT: int = 31
const VISUALIZATION_AREA_WIDTH: int = 1600 - MARGIN_SIZE * 2
const VISUALIZATION_AREA_HEIGHT: int = 900 - BUTTON_HEIGHT - MARGIN_SIZE * 2
const BAR_WIDTH: int = floori(float(VISUALIZATION_AREA_WIDTH) / MAX_SIZE)
const BAR_HEIGHT: int = floori(float(VISUALIZATION_AREA_HEIGHT) / MAX_SIZE)
const BAR_DEFAULT_COLOR: Color = Color(0.25, 0.6, 0.95, 1.0)
const BAR_SELECTED_COLOR: Color = Color(1.0, 0.25, 0.25, 1.0)
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
		apply_panel_style(panel, BAR_DEFAULT_COLOR)

		column.add_child(panel)
		panels.append(panel)
		sort_visualization_area.add_child(column)

func _on_shuffle_button_pressed() -> void:
	sort_values.shuffle()
	redraw_visualization_area()

func _on_run_sort_button_pressed() -> void:
	match select_sort_option.text:
		"Bubble Sort":
			bubble_sort()
		"Merge Sort":
			merge_sort()

func bubble_sort() -> void:
	var start_time: float = Time.get_ticks_msec()
	var loop_count: int = 0
	for i in sort_values.size() - 1:
		for j in range(0, sort_values.size() - i - 1):
			loop_count += 1
			highlight_panel(j+1) # j+1 の位置の Panel だけ背景色を赤にする

			if sort_values[j] > sort_values[j + 1]:
				var temp: int = sort_values[j]
				sort_values[j] = sort_values[j + 1]
				sort_values[j + 1] = temp
				redraw_visualization_area()

			status_label.text = create_status_text("Running", start_time, loop_count)
			await get_tree().create_timer(0.01).timeout

	highlight_panel(-1) # 全ての Panel の背景色をデフォルトに戻すため、範囲外の数値を渡す
	status_label.text = create_status_text("Done", start_time, loop_count)

func merge_sort() -> void:
	var start_time: float = Time.get_ticks_msec()
	var loop_count: int = 0
	var n: int = sort_values.size()
	var width: int = 1

	while width < n:
		for left in range(0, n, width * 2):
			var mid: int = mini(left + width, n)
			var right: int = mini(left + width * 2, n)
			if mid >= right:
				continue

			var left_part: Array[int] = []
			for i in range(left, mid):
				left_part.append(sort_values[i])

			var right_part: Array[int] = []
			for i in range(mid, right):
				right_part.append(sort_values[i])

			var li: int = 0
			var ri: int = 0
			var write_index: int = left

			while li < left_part.size() and ri < right_part.size():
				loop_count += 1
				highlight_panel(write_index)

				if left_part[li] <= right_part[ri]:
					sort_values[write_index] = left_part[li]
					li += 1
				else:
					sort_values[write_index] = right_part[ri]
					ri += 1

				redraw_visualization_area()
				status_label.text = create_status_text("Running", start_time, loop_count)
				await get_tree().create_timer(0.01).timeout
				write_index += 1

			while li < left_part.size():
				sort_values[write_index] = left_part[li]
				li += 1
				loop_count += 1
				highlight_panel(write_index)
				redraw_visualization_area()
				status_label.text = create_status_text("Running", start_time, loop_count)
				await get_tree().create_timer(0.01).timeout
				write_index += 1

			while ri < right_part.size():
				sort_values[write_index] = right_part[ri]
				ri += 1
				loop_count += 1
				highlight_panel(write_index)
				redraw_visualization_area()
				status_label.text = create_status_text("Running", start_time, loop_count)
				await get_tree().create_timer(0.01).timeout
				write_index += 1

		width *= 2

	highlight_panel(-1) # 全ての Panel の背景色をデフォルトに戻す
	status_label.text = create_status_text("Done", start_time, loop_count)

func redraw_visualization_area() -> void:
	for i in range(MAX_SIZE):
		panels[i].custom_minimum_size = Vector2(0, BAR_HEIGHT * sort_values[i])

func highlight_panel(selected_index: int) -> void:
	for i in range(panels.size()):
		var color: Color = BAR_SELECTED_COLOR if i == selected_index else BAR_DEFAULT_COLOR
		apply_panel_style(panels[i], color)

func apply_panel_style(panel: Panel, color: Color) -> void:
	var style_box := StyleBoxFlat.new()
	style_box.bg_color = color
	style_box.corner_radius_top_left = 0
	style_box.corner_radius_top_right = 0
	style_box.corner_radius_bottom_right = 0
	style_box.corner_radius_bottom_left = 0
	panel.add_theme_stylebox_override("panel", style_box)

func create_status_text(text: String, start_time: float, loop_count: int) -> String:
	var elapsed_time: float = Time.get_ticks_msec() - start_time
	return "%s %dms, %d loops" % [text, elapsed_time, loop_count]