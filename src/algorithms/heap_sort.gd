class_name HeapSort

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
	var size: int = sort_values.size()

	for i in range(floori(float(size) / 2.0) - 1, -1, -1):
		await _heapify(size, i, start_time, loop_count_box)

	for end_index in range(size - 1, 0, -1):
		var temp: int = sort_values[0].get_value()
		sort_values[0].set_value(sort_values[end_index].get_value())
		sort_values[end_index].set_value(temp)

		loop_count_box[0] += 1
		await on_step.call(end_index, start_time, loop_count_box[0])
		await wait.call()
		await _heapify(end_index, 0, start_time, loop_count_box)

	await on_done.call(start_time, loop_count_box[0])

func _heapify(heap_size: int, root_index: int, start_time: float, loop_count_box: Array[int]) -> void:
	var largest: int = root_index
	var left: int = 2 * root_index + 1
	var right: int = 2 * root_index + 2

	if left < heap_size:
		loop_count_box[0] += 1
		await on_step.call(left, start_time, loop_count_box[0])
		await wait.call()
		if sort_values[left].get_value() > sort_values[largest].get_value():
			largest = left

	if right < heap_size:
		loop_count_box[0] += 1
		await on_step.call(right, start_time, loop_count_box[0])
		await wait.call()
		if sort_values[right].get_value() > sort_values[largest].get_value():
			largest = right

	if largest != root_index:
		var temp: int = sort_values[root_index].get_value()
		sort_values[root_index].set_value(sort_values[largest].get_value())
		sort_values[largest].set_value(temp)

		loop_count_box[0] += 1
		await on_step.call(largest, start_time, loop_count_box[0])
		await wait.call()
		await _heapify(heap_size, largest, start_time, loop_count_box)
