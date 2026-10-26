@tool
# Having a class name is handy for picking the effect in the Inspector.
class_name RichTextFancyNameEffect
extends RichTextEffect


# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [fancy_name_effect param=2.0]hello[/fancy_name_effect] in text.
var bbcode := "fancy_name"


func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	var clr1: Color = char_fx.env.get("clr1", Color(1.0, 1.0, 1.0, 1.0))
	var clr2: Color = char_fx.env.get("clr2", Color(1.0, 0.924, 0.73, 1.0))
	
	
	char_fx.offset += Vector2(cos(char_fx.elapsed_time + char_fx.relative_index) * 0.3, sin(char_fx.elapsed_time - char_fx.relative_index*0.666))
	char_fx.color = clr1.lerp(
		clr2,
		pow((sin(char_fx.elapsed_time*2 - char_fx.relative_index*0.4) + 1) * 0.5, 3),
	)
	
	return true
