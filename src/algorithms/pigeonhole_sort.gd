class_name PigeonholeSort

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

	var temp_values: Array[int] = []
	temp_values.resize(sort_values.size())
	for i in range(sort_values.size()):
		step_count += 1
		var value: int = sort_values[i].get_value()
		temp_values[i] = value
		await on_step.call(i, start_time, step_count)
		await wait.call()

	for i in range(temp_values.size()):
		step_count += 1
		var value: int = temp_values[i]
		sort_values[value - 1].set_value(value)
		await on_step.call(value - 1, start_time, step_count)
		await wait.call()

	await on_done.call(start_time, step_count)
