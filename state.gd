class_name State
extends Node



## Reference to the state machine (set by the StateMachine)
var state_machine: StateMachine


## Return true if this is the currently active state.
func is_active_state() -> bool:
	if state_machine and state_machine.current_state == self:
		return true
	return false


## Called when entering this state
func enter() -> void:
	pass

## Called when leaving this state
func exit() -> void:
	pass

## Called every physics frame while this state is active
func physics_update(_delta: float) -> void:
	pass

## Called every frame while this state is active
func update(_delta: float) -> void:
	pass
