class_name InsertionSort

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

	for i in range(1, sort_values.size()):
		var key: int = sort_values[i].get_value()
		var j: int = i - 1

		while j >= 0 and sort_values[j].get_value() > key:
			step_count += 1
			sort_values[j + 1].set_value(sort_values[j].get_value())
			await on_step.call(j, start_time, step_count)
			await wait.call()
			j -= 1

		sort_values[j + 1].set_value(key)
		step_count += 1
		await on_step.call(j + 1, start_time, step_count)
		await wait.call()

	await on_done.call(start_time, step_count)
