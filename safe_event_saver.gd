extends Resource
class_name SafeEventSaver

# The explicit purpose of this module is to handle multiple different EventTypes:
@warning_ignore_start("incompatible_ternary")


enum TYPE{
	key,
	mouse_button,
	joy_button,
	action,
}

## Maps the relevant property names (that must be saved/loaded for the events to work) for each event type
static var code_properties_for_type: Dictionary[TYPE, Array] = {
	TYPE.key: ["keycode", "physical_keycode"],
	TYPE.mouse_button: ["button_index"],
	TYPE.joy_button: ["button_index"],
	TYPE.action: ["action"],
}


static func event_to_dict(event: InputEvent) -> Dictionary[String, Variant]:
	var event_dict: Dictionary[String, Variant] = {}
	event_dict["type"] = (
		TYPE.mouse_button if event is InputEventMouseButton
		else TYPE.joy_button if event is InputEventJoypadButton
		else TYPE.action if event is InputEventAction
		else TYPE.key
	)
	var codes: Array[Variant] = []
	for code_property in code_properties_for_type[event_dict["type"]]:
		codes.append(event.get(code_property))
	event_dict["codes"] = codes
	return event_dict


static func event_from_dict(dictionary: Dictionary[String, Variant]) -> InputEvent:
	if "codes" not in dictionary or "type" not in dictionary:
		push_error("`SafeEventLoader.event_from_dict` dictionary was malformed: ", dictionary)
		return null

	var event: InputEvent = (
		InputEventMouseButton.new() if dictionary['type'] == TYPE.mouse_button
		else InputEventJoypadButton.new() if dictionary['type'] == TYPE.joy_button
		else InputEventAction.new() if dictionary['type'] == TYPE.action
		else InputEventKey.new()
	)
	for idx in len(dictionary["codes"]):
		var code: Variant = dictionary["codes"][idx]
		var code_property: StringName = code_properties_for_type[dictionary["type"]][idx]
		event.set(code_property, code)
	return event
