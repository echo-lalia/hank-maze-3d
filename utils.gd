extends RefCounted
class_name Utils


static func event_as_key_string(event: InputEvent) -> String:
	return (
		event.as_text().to_upper()
		.trim_suffix(" (PHYSICAL)")
		.trim_suffix(" - PHYSICAL")
	)


static func seconds_to_timer(time: float) -> String:
	@warning_ignore("narrowing_conversion")
	var _seconds: int = time
	
	@warning_ignore("integer_division")
	var _minutes: int = _seconds / 60
	_seconds -= _minutes * 60
	time -= _minutes * 60
	
	@warning_ignore("narrowing_conversion")
	var _miliseconds: int = (time - _seconds) * 1000
	
	return (
		str(_minutes) + ":" + str(_seconds) + "." + (str(_miliseconds).lpad(3, "0"))
	)


## Get the relative direction to a target node from a reference node.
## (Used for finding out what direction an object is in, for the player.)
static func get_relative_direction(_reference: Node3D, target: Node3D) -> float:
	# Use the relative up and forward direction from the reference point.
	var up: Vector3 = _reference.global_transform.basis.y.normalized()
	var forward: Vector3 = -_reference.global_transform.basis.z
	var direction: Vector3 = target.global_position - _reference.global_position

	return forward.signed_angle_to(direction, up)



## Map a value between a minimum and maximum value to a float from 0 to 1 (unclamped)
static func range_to_fract(value: float, minimum: float, maximum: float) -> float:
	var delta: float = maximum - minimum
	if not delta:
		return 0.0
	return (value - minimum) / delta


# Map a value from one range, to another
static func map_range(value: float, in_min: float, in_max: float, out_min: float, out_max: float) -> float:
	return lerpf(out_min, out_max, range_to_fract(value, in_min, in_max))


## Simplify floating point numbers for pretty display
static func simple_format_number(number: float) -> String:
	if is_equal_approx(number, int(number)):
		return str(int(number))
	return "%.1f" % number


## Create a timer for the specified duration, scaled by animation scale, and return its timout signal.
static func timer_timeout(duration: float) -> Signal:
	return Main.current_main_instance.get_tree().create_timer(duration).timeout


## Easily call a function after a delay
static func call_delayed(callable: Callable, delay: float) -> void:
	await timer_timeout(delay)
	callable.call()


## Quickly create a tween and animate a property from start to end
static func animate(
	node: Node, property: NodePath, start: Variant, end: Variant, time: float,
	_ease: Tween.EaseType = Tween.EASE_IN_OUT, trans: Tween.TransitionType = Tween.TRANS_LINEAR) -> Tween:
	var tween: Tween = node.create_tween()
	tween.set_ease(_ease).set_trans(trans)
	
	tween.tween_property(node, property, start, 0.0)
	tween.tween_property(node, property, end, time)
	return tween


## Quickly create a tween and animate a callable from start to end
static func animate_method(
	node: Node, callable: Callable, start: Variant, end: Variant, time: float,
	_ease: Tween.EaseType = Tween.EASE_IN_OUT, trans: Tween.TransitionType = Tween.TRANS_LINEAR) -> void:
	var tween: Tween = node.create_tween()
	tween.set_ease(_ease).set_trans(trans)
	
	tween.tween_method(callable, start, end, time)
