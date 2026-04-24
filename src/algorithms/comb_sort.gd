class_name CombSort

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
	var gap: int = sort_values.size()
	var shrink: float = 1.3
	var swapped: bool = true

	while gap > 1 or swapped:
		gap = floori(float(gap) / shrink)
		if gap < 1:
			gap = 1

		swapped = false
		for i in range(0, sort_values.size() - gap):
			var j: int = i + gap
			step_count += 1
			if sort_values[i].get_value() > sort_values[j].get_value():
				var temp: int = sort_values[i].get_value()
				sort_values[i].set_value(sort_values[j].get_value())
				sort_values[j].set_value(temp)
				swapped = true
			await on_step.call(j, start_time, step_count)
			await wait.call()

	await on_done.call(start_time, step_count)
