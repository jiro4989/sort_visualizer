class_name ShellSort

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
	var gap: int = floori(float(sort_values.size()) / 2.0)

	while gap > 0:
		for i in range(gap, sort_values.size()):
			var temp: int = sort_values[i].get_value()
			var j: int = i

			while j >= gap and sort_values[j - gap].get_value() > temp:
				step_count += 1
				sort_values[j].set_value(sort_values[j - gap].get_value())
				await on_step.call(j, start_time, step_count)
				await wait.call()
				j -= gap

			sort_values[j].set_value(temp)
			step_count += 1
			await on_step.call(j, start_time, step_count)
			await wait.call()

		gap = floori(float(gap) / 2.0)

	await on_done.call(start_time, step_count)
