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
const SLEEP_TIME: float = 0.01
var sort_values: Array[SortBar] = []

func _ready() -> void:
	# 可視化エリアの初期化
	for i in range(MAX_SIZE):
		var sort_bar: SortBar = SortBar.new(i+1, BAR_WIDTH, BAR_HEIGHT, BAR_DEFAULT_COLOR)
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

## 指定したインデックスの Panel の背景色を変更する。
func highlight_panel(selected_index: int) -> void:
	for i in range(sort_values.size()):
		sort_values[i].apply_panel_style(BAR_SELECTED_COLOR if i == selected_index else BAR_DEFAULT_COLOR)

## ステータステキストを作成する。
func create_status_text(text: String, start_time: float, loop_count: int) -> String:
	var elapsed_time: float = Time.get_ticks_msec() - start_time
	return "%s %dms, %d step" % [text, elapsed_time, loop_count]

func _on_run_sort_button_pressed() -> void:
	sort(select_sort_option.text)

func sort(sort_type: String) -> void:
	match sort_type:
		"Bubble Sort":
			bubble_sort()
		"Merge Sort":
			merge_sort()
		"Insertion Sort":
			insertion_sort()
		"Selection Sort":
			selection_sort()
		"Shell Sort":
			shell_sort()
		"Heap Sort":
			heap_sort()
		"Quick Sort":
			quick_sort()

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

			status_label.text = create_status_text("Running", start_time, loop_count)
			await get_tree().create_timer(SLEEP_TIME).timeout

	highlight_panel(-1) # 全ての Panel の背景色をデフォルトに戻すため、範囲外の数値を渡す
	status_label.text = create_status_text("Done", start_time, loop_count)

## マージソートを実行する。
func merge_sort() -> void:
	var start_time: float = Time.get_ticks_msec()
	var values: Array[int] = []
	var loop_count_box: Array[int] = [0]

	for i in range(sort_values.size()):
		values.append(sort_values[i].get_value())

	if values.size() > 1:
		await _merge_sort_range(values, 0, values.size() - 1, start_time, loop_count_box)

	highlight_panel(-1) # 全ての Panel の背景色をデフォルトに戻す
	status_label.text = create_status_text("Done", start_time, loop_count_box[0])

func _merge_sort_range(values: Array[int], left: int, right: int, start_time: float, loop_count_box: Array[int]) -> void:
	if left >= right:
		return

	var mid: int = floori(float(left + right) / 2.0)
	await _merge_sort_range(values, left, mid, start_time, loop_count_box)
	await _merge_sort_range(values, mid + 1, right, start_time, loop_count_box)
	await _merge(values, left, mid, right, start_time, loop_count_box)

func _merge(values: Array[int], left: int, mid: int, right: int, start_time: float, loop_count_box: Array[int]) -> void:
	var left_part: Array[int] = []
	var right_part: Array[int] = []

	for i in range(left, mid + 1):
		left_part.append(values[i])
	for i in range(mid + 1, right + 1):
		right_part.append(values[i])

	var left_index: int = 0
	var right_index: int = 0
	var merged_index: int = left

	while left_index < left_part.size() and right_index < right_part.size():
		if left_part[left_index] <= right_part[right_index]:
			values[merged_index] = left_part[left_index]
			left_index += 1
		else:
			values[merged_index] = right_part[right_index]
			right_index += 1
		await _apply_merge_step(values, merged_index, start_time, loop_count_box)
		merged_index += 1

	while left_index < left_part.size():
		values[merged_index] = left_part[left_index]
		left_index += 1
		await _apply_merge_step(values, merged_index, start_time, loop_count_box)
		merged_index += 1

	while right_index < right_part.size():
		values[merged_index] = right_part[right_index]
		right_index += 1
		await _apply_merge_step(values, merged_index, start_time, loop_count_box)
		merged_index += 1

func _apply_merge_step(values: Array[int], index: int, start_time: float, loop_count_box: Array[int]) -> void:
	sort_values[index].set_value(values[index])
	loop_count_box[0] += 1
	highlight_panel(index)
	status_label.text = create_status_text("Running", start_time, loop_count_box[0])
	await get_tree().create_timer(SLEEP_TIME).timeout

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
			status_label.text = create_status_text("Running", start_time, loop_count)
			await get_tree().create_timer(SLEEP_TIME).timeout
			j -= 1

		sort_values[j + 1].set_value(key)
		loop_count += 1
		highlight_panel(j + 1)
		status_label.text = create_status_text("Running", start_time, loop_count)
		await get_tree().create_timer(SLEEP_TIME).timeout

	highlight_panel(-1) # 全ての Panel の背景色をデフォルトに戻す
	status_label.text = create_status_text("Done", start_time, loop_count)

## 選択ソートを実行する。
func selection_sort() -> void:
	var start_time: float = Time.get_ticks_msec()
	var loop_count: int = 0

	for i in range(sort_values.size() - 1):
		var min_index: int = i
		for j in range(i + 1, sort_values.size()):
			loop_count += 1
			highlight_panel(j)
			if sort_values[j].get_value() < sort_values[min_index].get_value():
				min_index = j
			status_label.text = create_status_text("Running", start_time, loop_count)
			await get_tree().create_timer(SLEEP_TIME).timeout

		if min_index != i:
			var temp: int = sort_values[i].get_value()
			sort_values[i].set_value(sort_values[min_index].get_value())
			sort_values[min_index].set_value(temp)

		loop_count += 1
		highlight_panel(i)
		status_label.text = create_status_text("Running", start_time, loop_count)
		await get_tree().create_timer(SLEEP_TIME).timeout

	highlight_panel(-1)
	status_label.text = create_status_text("Done", start_time, loop_count)

## シェルソートを実行する。
func shell_sort() -> void:
	var start_time: float = Time.get_ticks_msec()
	var loop_count: int = 0
	var gap: int = floori(float(sort_values.size()) / 2.0)

	while gap > 0:
		for i in range(gap, sort_values.size()):
			var temp: int = sort_values[i].get_value()
			var j: int = i

			while j >= gap and sort_values[j - gap].get_value() > temp:
				loop_count += 1
				highlight_panel(j)
				sort_values[j].set_value(sort_values[j - gap].get_value())
				status_label.text = create_status_text("Running", start_time, loop_count)
				await get_tree().create_timer(SLEEP_TIME).timeout
				j -= gap

			sort_values[j].set_value(temp)
			loop_count += 1
			highlight_panel(j)
			status_label.text = create_status_text("Running", start_time, loop_count)
			await get_tree().create_timer(SLEEP_TIME).timeout

		gap = floori(float(gap) / 2.0)

	highlight_panel(-1)
	status_label.text = create_status_text("Done", start_time, loop_count)

## ヒープソートを実行する。
func heap_sort() -> void:
	var start_time: float = Time.get_ticks_msec()
	var loop_count_box: Array[int] = [0]
	var size: int = sort_values.size()

	for i in range(floori(float(size) / 2.0) - 1, -1, -1):
		await _heapify(size, i, start_time, loop_count_box)

	for end_index in range(size - 1, 0, -1):
		var temp: int = sort_values[0].get_value()
		sort_values[0].set_value(sort_values[end_index].get_value())
		sort_values[end_index].set_value(temp)

		loop_count_box[0] += 1
		highlight_panel(end_index)
		status_label.text = create_status_text("Running", start_time, loop_count_box[0])
		await get_tree().create_timer(SLEEP_TIME).timeout

		await _heapify(end_index, 0, start_time, loop_count_box)

	highlight_panel(-1)
	status_label.text = create_status_text("Done", start_time, loop_count_box[0])

func _heapify(heap_size: int, root_index: int, start_time: float, loop_count_box: Array[int]) -> void:
	var largest: int = root_index
	var left: int = 2 * root_index + 1
	var right: int = 2 * root_index + 2

	if left < heap_size:
		loop_count_box[0] += 1
		highlight_panel(left)
		status_label.text = create_status_text("Running", start_time, loop_count_box[0])
		await get_tree().create_timer(SLEEP_TIME).timeout
		if sort_values[left].get_value() > sort_values[largest].get_value():
			largest = left

	if right < heap_size:
		loop_count_box[0] += 1
		highlight_panel(right)
		status_label.text = create_status_text("Running", start_time, loop_count_box[0])
		await get_tree().create_timer(SLEEP_TIME).timeout
		if sort_values[right].get_value() > sort_values[largest].get_value():
			largest = right

	if largest != root_index:
		var temp: int = sort_values[root_index].get_value()
		sort_values[root_index].set_value(sort_values[largest].get_value())
		sort_values[largest].set_value(temp)

		loop_count_box[0] += 1
		highlight_panel(largest)
		status_label.text = create_status_text("Running", start_time, loop_count_box[0])
		await get_tree().create_timer(SLEEP_TIME).timeout

		await _heapify(heap_size, largest, start_time, loop_count_box)

## クイックソートを実行する。
func quick_sort() -> void:
	var start_time: float = Time.get_ticks_msec()
	var loop_count_box: Array[int] = [0]

	if sort_values.size() > 1:
		await _quick_sort_range(0, sort_values.size() - 1, start_time, loop_count_box)

	highlight_panel(-1)
	status_label.text = create_status_text("Done", start_time, loop_count_box[0])

func _quick_sort_range(low: int, high: int, start_time: float, loop_count_box: Array[int]) -> void:
	if low >= high:
		return

	var pivot_index: int = await _partition(low, high, start_time, loop_count_box)
	await _quick_sort_range(low, pivot_index - 1, start_time, loop_count_box)
	await _quick_sort_range(pivot_index + 1, high, start_time, loop_count_box)

func _partition(low: int, high: int, start_time: float, loop_count_box: Array[int]) -> int:
	var pivot_value: int = sort_values[high].get_value()
	var store_index: int = low

	for scan_index in range(low, high):
		loop_count_box[0] += 1
		highlight_panel(scan_index)
		status_label.text = create_status_text("Running", start_time, loop_count_box[0])
		await get_tree().create_timer(SLEEP_TIME).timeout

		if sort_values[scan_index].get_value() <= pivot_value:
			if store_index != scan_index:
				var temp: int = sort_values[store_index].get_value()
				sort_values[store_index].set_value(sort_values[scan_index].get_value())
				sort_values[scan_index].set_value(temp)
			store_index += 1

	loop_count_box[0] += 1
	highlight_panel(store_index)
	status_label.text = create_status_text("Running", start_time, loop_count_box[0])
	await get_tree().create_timer(SLEEP_TIME).timeout

	if store_index != high:
		var temp: int = sort_values[store_index].get_value()
		sort_values[store_index].set_value(sort_values[high].get_value())
		sort_values[high].set_value(temp)

	return store_index
