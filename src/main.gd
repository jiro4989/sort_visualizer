extends Node2D

@onready var shuffle_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/ShuffleButton
@onready var select_sort_option: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer/SelectSortOption
@onready var run_sort_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/RunSortButton
@onready var sort_visualization_area: HBoxContainer = $MarginContainer/VBoxContainer/SortVisualizationArea
@onready var status_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/StatusLabel

@onready var select_element_count_option: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer2/SelectElementCountOption
@onready var select_volume_option: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer2/SelectVolumeOption
@onready var select_wait_time_option: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer2/SelectWaitTimeOption
@onready var select_animation_option: OptionButton = $MarginContainer/VBoxContainer/HBoxContainer2/SelectAnimationOption

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

const MARGIN_SIZE: int = 6
const BUTTON_HEIGHT: int = 31
const VISUALIZATION_AREA_WIDTH: int = 1600 - MARGIN_SIZE * 2
const VISUALIZATION_AREA_HEIGHT: int = 900 - BUTTON_HEIGHT * 2 - MARGIN_SIZE * 4
const BAR_DEFAULT_COLOR: Color = Color(0.25, 0.6, 0.95, 1.0)
const BAR_SELECTED_COLOR: Color = Color(1.0, 0.25, 0.25, 1.0)

const MESSAGE_RUNNING: String = "Running"
const MESSAGE_DONE: String = "Done"

var sort_values: Array[SortBar] = []
var sound_controller: SoundController

var bubble_sort: BubbleSort = BubbleSort.new(sort_values, _on_step, _on_done, wait)
var merge_sort: MergeSort = MergeSort.new(sort_values, _on_step, _on_done, wait)
var insertion_sort: InsertionSort = InsertionSort.new(sort_values, _on_step, _on_done, wait)
var selection_sort: SelectionSort = SelectionSort.new(sort_values, _on_step, _on_done, wait)
var shell_sort: ShellSort = ShellSort.new(sort_values, _on_step, _on_done, wait)
var heap_sort: HeapSort = HeapSort.new(sort_values, _on_step, _on_done, wait)
var quick_sort: QuickSort = QuickSort.new(sort_values, _on_step, _on_done, wait)
var pigeonhole_sort: PigeonholeSort = PigeonholeSort.new(sort_values, _on_step, _on_done, wait)
var radix_sort: RadixSort = RadixSort.new(sort_values, _on_step, _on_done, wait)
var bucket_sort: BucketSort = BucketSort.new(sort_values, _on_step, _on_done, wait)
var gnome_sort: GnomeSort = GnomeSort.new(sort_values, _on_step, _on_done, wait)
var shaker_sort: ShakerSort = ShakerSort.new(sort_values, _on_step, _on_done, wait)
var comb_sort: CombSort = CombSort.new(sort_values, _on_step, _on_done, wait)

# ソートアルゴリズムを追加するたびに tscn ファイルを編集するのが面倒なので
# Option 要素はコードですべて定義して、初期化時に Item を追加する。
var sort_algorithms: Array[Sorter] = [
	Sorter.new("Bubble Sort", bubble_sort.sort),
	Sorter.new("Merge Sort", merge_sort.sort),
	Sorter.new("Insertion Sort", insertion_sort.sort),
	Sorter.new("Selection Sort", selection_sort.sort),
	Sorter.new("Shell Sort", shell_sort.sort),
	Sorter.new("Heap Sort", heap_sort.sort),
	Sorter.new("Quick Sort", quick_sort.sort),
	Sorter.new("Pigeonhole Sort", pigeonhole_sort.sort),
	Sorter.new("Radix Sort", radix_sort.sort),
	Sorter.new("Bucket Sort", bucket_sort.sort),
	Sorter.new("Gnome Sort", gnome_sort.sort),
	Sorter.new("Shaker Sort", shaker_sort.sort),
	Sorter.new("Comb Sort", comb_sort.sort),
]

# 配列のループで要素を取り出すのは基本的に遅いので
# 辞書に詰め直してキーでアクセスできるようにしておく。
var sort_algorithms_map: Dictionary[String, Sorter] = {}

func _ready() -> void:
	setup_visualization_layout()
	sound_controller = SoundController.new(audio_stream_player)
	setup_sort_algorithm()
	setup_sort_values()
	shuffle_sort_values()

## ソート中に上段 UI の高さやスタイル差し替えで可視化エリアの割当高さが揺れないようにする。
func setup_visualization_layout() -> void:
	sort_visualization_area.custom_minimum_size.y = VISUALIZATION_AREA_HEIGHT
	sort_visualization_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	status_label.clip_text = true
	status_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	status_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func setup_sort_algorithm() -> void:
	for sorter in sort_algorithms:
		sort_algorithms_map[sorter.name] = sorter
		select_sort_option.add_item(sorter.name)

## ソート対象の値を初期化する。
func setup_sort_values() -> void:
	for child in sort_visualization_area.get_children():
		child.queue_free()
	sort_values.clear()
	var element_count: int = get_selected_element_count()
	var base_bar_width: int = floori(float(VISUALIZATION_AREA_WIDTH) / element_count)
	var width_remainder: int = VISUALIZATION_AREA_WIDTH - base_bar_width * element_count
	var bar_height: float = floori(float(VISUALIZATION_AREA_HEIGHT) / element_count)
	for i in range(element_count):
		var bar_width: int = base_bar_width + (1 if i < width_remainder else 0)
		var sort_bar: SortBar = SortBar.new(i+1, bar_width, bar_height, BAR_DEFAULT_COLOR)
		sort_values.append(sort_bar)
		sort_visualization_area.add_child(sort_bar.column)

func get_selected_element_count() -> int:
	var element_count_text: String = select_element_count_option.text
	return int(element_count_text)

func get_selected_wait_time_seconds() -> float:
	# UI 上の待機時間がミリ秒だが、GDScript の待機時間は秒単位なのでミリ秒を秒に変換する。
	var wait_time_text: String = select_wait_time_option.text
	return float(wait_time_text) / 1000.0

## 待機時間を UI 上で設定した秒数分待機する。
func wait() -> void:
	await wait_seconds(get_selected_wait_time_seconds())

## 指定した秒数分待機する。
func wait_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout

func _on_shuffle_button_pressed() -> void:
	shuffle_sort_values()

func _on_select_element_count_option_item_selected(__index: int) -> void:
	setup_sort_values()
	shuffle_sort_values()
	setup_animation()

## アニメーションの有効無効を切り替える。
func _on_select_animation_option_item_selected(__index):
	setup_animation()

func setup_animation() -> void:
	var enable_animation: bool = select_animation_option.text == "true"
	for i in range(sort_values.size()):
		sort_values[i].set_enable_animation(enable_animation)

## Panel の参照自体はそのままで、sort_value の値のみシャッフルする。
##
## sort_values は Panel を内包するため、sort_values 自体をシャッフルすると
## value とともに Panel の参照も移動してしまうため、結果的に
## UI 上では変化していないように見えてしまうため、sort_value の値のみシャッフルする。
func shuffle_sort_values() -> void:
	var values: Array[int] = []
	for i in range(sort_values.size()):
		values.append(sort_values[i].get_value())
	values.shuffle()
	for i in range(sort_values.size()):
		sort_values[i].set_value(values[i])

## 指定したインデックスのバーの背景色を変更する。
##
## -1 を指定すると全てのバーの背景色をデフォルトに戻す。
func highlight_bar(selected_index: int) -> void:
	for i in range(sort_values.size()):
		sort_values[i].apply_panel_style(BAR_SELECTED_COLOR if i == selected_index else BAR_DEFAULT_COLOR)
	sound_controller.play_sound(
		selected_index,
		sort_values,
		get_selected_element_count(),
		get_selected_volume_scale()
	)

## 全てのバーの背景色をデフォルトに戻す。
func highlight_off() -> void:
	highlight_bar(-1)

## 先頭から順にハイライトして、最後に全てのバーの背景色をデフォルトに戻す。
## 主にソート完了後の強調目的で使用する。
func highlight_all_bars() -> void:
	for i in range(sort_values.size()):
		highlight_bar(i)
		# このハイライトはソート完了後の強調表示に過ぎないため、
		# さっさと処理を終わらせた方が体験が良いと思うので、待機時間を固定で小さい値とする。
		await wait_seconds(0.01)
	highlight_off()

## ステータステキストを作成する。
func create_status_text(text: String, start_time: float, step_count: int) -> String:
	var elapsed_seconds: float = (Time.get_ticks_msec() - start_time) / 1000.0
	return "%s: %.1fs, %d step" % [text, elapsed_seconds, step_count]

## 音量スケールを取得する。
## 音量は UI 上で百分率で設定しているため、小数に変換してから返却する。
func get_selected_volume_scale() -> float:
	var volume_text: String = select_volume_option.text
	var volume_percent: float = clampf(volume_text.to_float(), 0.0, 100.0)
	return volume_percent / 100.0

func _on_run_sort_button_pressed() -> void:
	shuffle_button.disabled = true
	run_sort_button.disabled = true
	select_element_count_option.disabled = true
	select_animation_option.disabled = true

	await sort(select_sort_option.text)
	await highlight_all_bars()

	shuffle_button.disabled = false
	run_sort_button.disabled = false
	select_element_count_option.disabled = false
	select_animation_option.disabled = false

## ソート処理中の各ステップで呼び出す関数。
## バーのハイライトとテキストの更新を行う。
func _on_step(selected_index: int, start_time: float, step_count: int) -> void:
	highlight_bar(selected_index)
	status_label.text = create_status_text(MESSAGE_RUNNING, start_time, step_count)

## ソート処理が完了したときに呼び出す関数。
## バーのハイライトを解除し、テキストを更新する。
func _on_done(start_time: float, step_count: int) -> void:
	highlight_off()
	status_label.text = create_status_text(MESSAGE_DONE, start_time, step_count)

func sort(sort_type: String) -> void:
	await sort_algorithms_map[sort_type].sort.call()