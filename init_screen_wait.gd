extends Control
class_name InitScreen


static var current_init_screen: InitScreen

const INIT_SCREEN_STUFF_INITIALIZER = preload("uid://bput33e27kes0")


signal finished_initializing

@onready var label: Label = $Label


var stuff_initializer: Node3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_init_screen = self
	
	label.text = "Initializing..."
	await get_tree().process_frame
	await get_tree().physics_frame
	stuff_initializer = INIT_SCREEN_STUFF_INITIALIZER.instantiate()
	add_child(stuff_initializer)
	
	for i in 6:
		await get_tree().process_frame
		await get_tree().physics_frame
	stuff_initializer.queue_free()
	finished_initializing.emit()
	
	label.text = "Summoning Hank..."
	for i in 12:
		await get_tree().process_frame
		await get_tree().physics_frame
	
	current_init_screen = null
	queue_free()


static func await_init_screen() -> void:
	if current_init_screen:
		while current_init_screen:
			await Main.current_main_instance.get_tree().process_frame
