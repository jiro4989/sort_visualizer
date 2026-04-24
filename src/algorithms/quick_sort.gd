class_name QuickSort

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
	var loop_count_box: Array[int] = [0]

	if sort_values.size() > 1:
		await _quick_sort_range(0, sort_values.size() - 1, start_time, loop_count_box)

	await on_done.call(start_time, loop_count_box[0])

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
		await on_step.call(scan_index, start_time, loop_count_box[0])
		await wait.call()

		if sort_values[scan_index].get_value() <= pivot_value:
			if store_index != scan_index:
				var temp: int = sort_values[store_index].get_value()
				sort_values[store_index].set_value(sort_values[scan_index].get_value())
				sort_values[scan_index].set_value(temp)
			store_index += 1

	loop_count_box[0] += 1
	await on_step.call(store_index, start_time, loop_count_box[0])
	await wait.call()

	if store_index != high:
		var temp: int = sort_values[store_index].get_value()
		sort_values[store_index].set_value(sort_values[high].get_value())
		sort_values[high].set_value(temp)

	return store_index
