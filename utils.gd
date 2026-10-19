extends RefCounted
class_name Utils


static func seconds_to_timer(time: float) -> String:
	@warning_ignore("narrowing_conversion")
	var _seconds: int = time
	
	@warning_ignore("integer_division")
	var _minutes: int = _seconds / 60
	_seconds -= (_minutes * 60)
	
	@warning_ignore("narrowing_conversion")
	var _miliseconds: int = (time - _seconds) * 1000
	
	return (
		str(_minutes) + ":" + str(_seconds) + "." + (str(_miliseconds).lpad(3, "0"))
	)
