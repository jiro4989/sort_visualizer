class_name RadixSort

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
	var values: Array[int] = []

	for i in range(sort_values.size()):
		values.append(sort_values[i].get_value())

	var max_value: int = 0
	for value in values:
		if value > max_value:
			max_value = value

	var digit_place: int = 1
	while floori(float(max_value) / digit_place) > 0:
		var count: Array[int] = []
		count.resize(10)
		for i in range(10):
			count[i] = 0

		var output: Array[int] = []
		output.resize(values.size())

		for i in range(values.size()):
			var digit: int = floori(float(values[i]) / digit_place) % 10
			count[digit] += 1
			step_count += 1
			await on_step.call(i, start_time, step_count)
			await wait.call()

		for i in range(1, 10):
			count[i] += count[i - 1]

		for i in range(values.size() - 1, -1, -1):
			var value: int = values[i]
			var digit: int = floori(float(value) / digit_place) % 10
			count[digit] -= 1
			var output_index: int = count[digit]
			output[output_index] = value
			step_count += 1
			await on_step.call(output_index, start_time, step_count)
			await wait.call()

		for i in range(values.size()):
			values[i] = output[i]
			sort_values[i].set_value(values[i])
			step_count += 1
			await on_step.call(i, start_time, step_count)
			await wait.call()

		digit_place *= 10

	await on_done.call(start_time, step_count)
