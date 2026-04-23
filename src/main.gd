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
var sort_values: Array[SortBar] = []

func _ready() -> void:
	# 可視化エリアの初期化
	for i in range(MAX_SIZE):
		var sort_bar: SortBar = SortBar.new(i+1, BAR_WIDTH, BAR_HEIGHT)
		sort_values.append(sort_bar)
		sort_visualization_area.add_child(sort_bar.column)
	shuffle_sort_values()

func _on_shuffle_button_pressed() -> void:
	shuffle_sort_values()

## Panel の参照自体はそのままで、sort_value の値のみシャッフルする。
##
## sort_values は Panel を内包するため、sort_values 自体をシャッフルすると
## value とともに Panel の参照も移動してしまうため、結果的に
## UI 上では変化していないように見えてしまうため、sort_value の値のみシャッフルする。
func shuffle_sort_values() -> void:
	var values: Array[int] = []
	for i in range(sort_values.size()):
		values.append(sort_values[i].get_value())
	values.shuffle()
	for i in range(sort_values.size()):
		sort_values[i].set_value(values[i])
	redraw_visualization_area()

func _on_run_sort_button_pressed() -> void:
	match select_sort_option.text:
		"Bubble Sort":
			bubble_sort()
		"Merge Sort":
			merge_sort()
		"Insertion Sort":
			insertion_sort()

## 可視化エリアの再描画。
func redraw_visualization_area() -> void:
	for i in range(sort_values.size()):
		sort_values[i].set_value(sort_values[i].get_value())

## 指定したインデックスの Panel の背景色を変更する。
func highlight_panel(selected_index: int) -> void:
	for i in range(sort_values.size()):
		sort_values[i].apply_panel_style(BAR_SELECTED_COLOR if i == selected_index else BAR_DEFAULT_COLOR)

## ステータステキストを作成する。
func create_status_text(text: String, start_time: float, loop_count: int) -> String:
	var elapsed_time: float = Time.get_ticks_msec() - start_time
	return "%s %dms, %d loops" % [text, elapsed_time, loop_count]

## バブルソートを実行する。
func bubble_sort() -> void:
	var start_time: float = Time.get_ticks_msec()
	var loop_count: int = 0
	for i in sort_values.size() - 1:
		for j in range(0, sort_values.size() - i - 1):
			loop_count += 1
			highlight_panel(j+1) # j+1 の位置の Panel だけ背景色を赤にする

			if sort_values[j].get_value() > sort_values[j + 1].get_value():
				var temp: int = sort_values[j].get_value()
				sort_values[j].set_value(sort_values[j + 1].get_value())
				sort_values[j + 1].set_value(temp)
				redraw_visualization_area()

			status_label.text = create_status_text("Running", start_time, loop_count)
			await get_tree().create_timer(0.01).timeout

	highlight_panel(-1) # 全ての Panel の背景色をデフォルトに戻すため、範囲外の数値を渡す
	status_label.text = create_status_text("Done", start_time, loop_count)

## マージソートを実行する。
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
					sort_values[write_index].set_value(left_part[li])
					li += 1
				else:
					sort_values[write_index].set_value(right_part[ri])
					ri += 1

				redraw_visualization_area()
				status_label.text = create_status_text("Running", start_time, loop_count)
				await get_tree().create_timer(0.01).timeout
				write_index += 1

			while li < left_part.size():
				sort_values[write_index].set_value(left_part[li])
				li += 1
				loop_count += 1
				highlight_panel(write_index)
				redraw_visualization_area()
				status_label.text = create_status_text("Running", start_time, loop_count)
				await get_tree().create_timer(0.01).timeout
				write_index += 1

			while ri < right_part.size():
				sort_values[write_index].set_value(right_part[ri])
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

## 挿入ソートを実行する。
func insertion_sort() -> void:
	var start_time: float = Time.get_ticks_msec()
	var loop_count: int = 0

	for i in range(1, sort_values.size()):
		var key: int = sort_values[i].get_value()
		var j: int = i - 1

		# key より大きい要素を右へずらす
		while j >= 0 and sort_values[j].get_value() > key:
			loop_count += 1
			highlight_panel(j)
			sort_values[j + 1].set_value(sort_values[j].get_value())
			redraw_visualization_area()
			status_label.text = create_status_text("Running", start_time, loop_count)
			await get_tree().create_timer(0.01).timeout
			j -= 1

		sort_values[j + 1].set_value(key)
		loop_count += 1
		highlight_panel(j + 1)
		redraw_visualization_area()
		status_label.text = create_status_text("Running", start_time, loop_count)
		await get_tree().create_timer(0.01).timeout

	highlight_panel(-1) # 全ての Panel の背景色をデフォルトに戻す
	status_label.text = create_status_text("Done", start_time, loop_count)
