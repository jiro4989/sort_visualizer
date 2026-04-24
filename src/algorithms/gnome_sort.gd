class_name GnomeSort

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
	var index: int = 1

	while index < sort_values.size():
		step_count += 1
		await on_step.call(index, start_time, step_count)
		await wait.call()

		if index == 0 or sort_values[index - 1].get_value() <= sort_values[index].get_value():
			index += 1
		else:
			var temp: int = sort_values[index].get_value()
			sort_values[index].set_value(sort_values[index - 1].get_value())
			sort_values[index - 1].set_value(temp)
			index -= 1

	await on_done.call(start_time, step_count)
