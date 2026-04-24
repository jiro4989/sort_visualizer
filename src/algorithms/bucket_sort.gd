class_name BucketSort

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

	if values.is_empty():
		await on_done.call(start_time, step_count)
		return

	var min_value: int = values[0]
	var max_value: int = values[0]
	for value in values:
		if value < min_value:
			min_value = value
		if value > max_value:
			max_value = value

	var bucket_count: int = maxi(1, floori(sqrt(float(values.size()))))
	var value_range: int = (max_value - min_value) + 1
	var buckets: Array = []
	buckets.resize(bucket_count)
	for i in range(bucket_count):
		buckets[i] = []

	for i in range(values.size()):
		var value: int = values[i]
		var normalized: int = value - min_value
		var bucket_index: int = mini(bucket_count - 1, floori(float(normalized * bucket_count) / value_range))
		buckets[bucket_index].append(value)
		step_count += 1
		await on_step.call(i, start_time, step_count)
		await wait.call()

	var write_index: int = 0
	for bucket in buckets:
		bucket.sort()
		for value in bucket:
			values[write_index] = value
			sort_values[write_index].set_value(value)
			step_count += 1
			await on_step.call(write_index, start_time, step_count)
			await wait.call()
			write_index += 1

	await on_done.call(start_time, step_count)
