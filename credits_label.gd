extends RichTextLabel


@export var lala: AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.




func _on_meta_hover_started(meta: Variant) -> void:
	match meta:
		"lala":
			lala.visible = true


func _on_meta_hover_ended(meta: Variant) -> void:
	match meta:
		"lala":
			lala.visible = false
