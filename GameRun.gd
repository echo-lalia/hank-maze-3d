extends Node3D
class_name GameRun



#signal won
#signal lost


@onready var bumpin_jingle_stream: AudioStreamPlayer = $BumpinJingleStream


static var current_game_run: GameRun


var run_start_time: float
var phase_two: bool = false

func get_engine_time() -> float:
	return Time.get_ticks_usec() / 1e+6


func _init() -> void:
	current_game_run = self


func _ready() -> void:
	await InitScreen.await_init_screen()
	run_start_time = get_engine_time()
	
	_enable_close_warning()
	_setup_browser_close_warning()



func _exit_tree() -> void:
	_disable_close_warning()



## Ctrl+W closes the current browser tab, and is also unfortunately a common key-combo in this type of game.
## Injecting this into the browser's javascript stops the window from unexpectly closing while playing.
## (I genuinely thought there was something silently crashing my entire web browser for a day and was losing my mind).
static var _browser_close_is_setup: bool = false
func _setup_browser_close_warning() -> void:
	if not OS.has_feature("web"):
		return
	
	if not _browser_close_is_setup:
		print("Injecting browser close warning to prevent accidental quits.")
		JavaScriptBridge.eval("""
			window.addEventListener('beforeunload', function (event) {
				if (window.enable_close_warning) {
					event.preventDefault();
					event.returnValue = '';
				}
			});
		""")
		_browser_close_is_setup = true


func _enable_close_warning() -> void:
	if not OS.has_feature("web"):
		return
	JavaScriptBridge.eval("window.enable_close_warning = true;")


func _disable_close_warning() -> void:
	if not OS.has_feature("web"):
		return
	JavaScriptBridge.eval("window.enable_close_warning = false;")



func get_run_time() -> float:
	return get_engine_time() - run_start_time



func start_phase_two() -> void:
	phase_two = true
	await get_tree().create_timer(0.666).timeout
	# Quick fade in and slow fade out
	var tween: = Utils.animate(bumpin_jingle_stream, "volume_db", -100, -8, 0.02)
	tween.tween_property(bumpin_jingle_stream, "volume_db", -12, 20)
	tween.tween_property(bumpin_jingle_stream, "volume_db", -20, 60)
	bumpin_jingle_stream.play()



static func phase2_switchf(phase1f: float, phase2f: float) -> float:
	return phase2f if current_game_run.phase_two else phase1f


#func win_game() -> void:
	#won.emit()
#
#
#func lose_game() -> void:
	#lost.emit()
