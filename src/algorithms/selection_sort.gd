class_name SelectionSort

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
	var step_count: int = 0

	for i in range(sort_values.size() - 1):
		var min_index: int = i
		for j in range(i + 1, sort_values.size()):
			step_count += 1
			if sort_values[j].get_value() < sort_values[min_index].get_value():
				min_index = j
			await on_step.call(j, start_time, step_count)
			await wait.call()

		if min_index != i:
			var temp: int = sort_values[i].get_value()
			sort_values[i].set_value(sort_values[min_index].get_value())
			sort_values[min_index].set_value(temp)

		step_count += 1
		await on_step.call(i, start_time, step_count)
		await wait.call()

	await on_done.call(start_time, step_count)
