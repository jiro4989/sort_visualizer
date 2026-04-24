class_name MergeSort

var sort_values: Array[SortBar]
var on_step: Callable
var on_done: Callable
var wait: Callable

func _init(_sort_values: Array[SortBar], _on_step: Callable, _on_done: Callable, _wait: Callable) -> void:
	sort_values = _sort_values
	on_step = _on_step
	on_done = _on_done
	wait = _wait

func sort() -> void:
	var start_time: float = Time.get_ticks_msec()
	var values: Array[int] = []
	var loop_count_box: Array[int] = [0]

	for i in range(sort_values.size()):
		values.append(sort_values[i].get_value())

	if values.size() > 1:
		await _merge_sort_range(values, 0, values.size() - 1, start_time, loop_count_box)

	await on_done.call(start_time, loop_count_box[0])

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
	await on_step.call(index, start_time, loop_count_box[0])
	await wait.call()
