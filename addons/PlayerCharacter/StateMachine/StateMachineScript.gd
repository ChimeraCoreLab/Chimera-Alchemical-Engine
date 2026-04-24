extends Node

@export var initialState : State

var currState : State
var currStateName  : String
var states : Dictionary = {}

@onready var charRef : CharacterBody3D = $".."

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(onStateChildTransition)
			
	if initialState:
		initialState.enter(charRef)
		currState = initialState
		currStateName = currState.stateName
		
func _process(delta : float):
	if currState: currState.update(delta)
	
func _physics_process(delta: float):
	if currState: currState.physics_update(delta)
	
func onStateChildTransition(state : State, newStateName : String):

	
	if state != currState: return
	
	var newState = states.get(newStateName.to_lower())
	if !newState: return
	

	if currState: currState.exit()

	newState.enter(charRef)
	
	currState = newState
	currStateName = currState.stateName
