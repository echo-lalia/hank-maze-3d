extends Control

@onready var label: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label.text = "Initializing..."
	await get_tree().process_frame
	await get_tree().physics_frame
	label.text = "Building level..."
	await get_tree().process_frame
	await get_tree().physics_frame
	label.text = "Baking geometry..."
	await get_tree().process_frame
	await get_tree().physics_frame
	label.text = "Summoning Hank..."
	await get_tree().process_frame
	await get_tree().physics_frame
	queue_free()
