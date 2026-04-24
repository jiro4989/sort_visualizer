class_name ShakerSort

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
	var left: int = 0
	var right: int = sort_values.size() - 1

	while left < right:
		var swapped: bool = false

		for i in range(left, right):
			step_count += 1
			if sort_values[i].get_value() > sort_values[i + 1].get_value():
				var temp: int = sort_values[i].get_value()
				sort_values[i].set_value(sort_values[i + 1].get_value())
				sort_values[i + 1].set_value(temp)
				swapped = true
			await on_step.call(i + 1, start_time, step_count)
			await wait.call()
		right -= 1

		if not swapped:
			break

		swapped = false
		for i in range(right, left, -1):
			step_count += 1
			if sort_values[i - 1].get_value() > sort_values[i].get_value():
				var temp: int = sort_values[i - 1].get_value()
				sort_values[i - 1].set_value(sort_values[i].get_value())
				sort_values[i].set_value(temp)
				swapped = true
			await on_step.call(i - 1, start_time, step_count)
			await wait.call()
		left += 1

		if not swapped:
			break

	await on_done.call(start_time, step_count)
