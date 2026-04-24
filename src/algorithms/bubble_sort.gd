class_name BubbleSort

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

	for i in sort_values.size() - 1:
		for j in range(0, sort_values.size() - i - 1):
			step_count += 1
			await on_step.call(j + 1, start_time, step_count)

			if sort_values[j].get_value() > sort_values[j + 1].get_value():
				var temp: int = sort_values[j].get_value()
				sort_values[j].set_value(sort_values[j + 1].get_value())
				sort_values[j + 1].set_value(temp)

			await wait.call()

	await on_done.call(start_time, step_count)
