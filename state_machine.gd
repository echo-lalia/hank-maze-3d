extends Node
class_name StateMachine


@export var initial_state: State

var current_state: State: set = _handle_state_change
	#set(val):
		#if current_state != val:
			#_handle_state_change(val)


func _handle_state_change(new_state: State) -> void:
	if current_state == new_state:
		return
	print("Changing hank state from ", current_state, " to ", new_state)
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter()


func _ready() -> void:
	# Give each child state a reference back to the machine.
	for child in get_children():
		if child is State:
			child.state_machine = self
	
	await InitScreen.await_init_screen()
	
	# Start in initial state
	current_state = initial_state


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
