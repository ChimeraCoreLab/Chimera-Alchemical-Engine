extends State

class_name IdleState

var stateName : String = "Idle"
var cR : CharacterBody3D

func enter(charRef : CharacterBody3D):
	cR = charRef
	verifications()
	
func verifications():
	if cR.floor_snap_length == 0.0: cR.floor_snap_length = 0.5
	cR.desiredMoveSpeed = 0.0
	
func physics_update(delta : float):
	applies(delta)
	cR.gravityApply(delta)
	inputManagement()
	move(delta)
	
func applies(delta : float):
	cR.hitbox.shape.height = lerp(cR.hitbox.shape.height, cR.baseHitboxHeight, cR.heightChangeSpeed * delta)
	cR.model.scale.y = lerp(cR.model.scale.y, cR.baseModelHeight, cR.heightChangeSpeed * delta)
	
	if cR.hitGroundCooldown > 0.0: cR.hitGroundCooldown -= delta

func inputManagement():
	if cR.jumpAction == "" or !InputMap.has_action(cR.jumpAction): return
	
	if Input.is_action_just_pressed(cR.jumpAction) and cR.is_on_floor():
		transitioned.emit(self, "JumpState")
		
	if cR.crouchAction != "" and InputMap.has_action(cR.crouchAction):
		if Input.is_action_pressed(cR.crouchAction):
			transitioned.emit(self, "CrouchState")

func move(delta : float):
	if cR.moveLeftAction == "" or !InputMap.has_action(cR.moveLeftAction): 
		cR.velocity.x = lerp(cR.velocity.x, 0.0, cR.moveDeccel * delta)
		cR.velocity.z = lerp(cR.velocity.z, 0.0, cR.moveDeccel * delta)
		return

	cR.inputDirection = Input.get_vector(cR.moveLeftAction, cR.moveRightAction, cR.moveForwardAction, cR.moveBackwardAction)
	cR.moveDirection = (cR.camHolder.global_basis * Vector3(cR.inputDirection.x, 0.0, cR.inputDirection.y)).normalized()
	
	if cR.moveDirection and cR.is_on_floor():
		transitioned.emit(self, cR.walkOrRun)
	else:
		cR.velocity.x = lerp(cR.velocity.x, 0.0, cR.moveDeccel * delta)
		cR.velocity.z = lerp(cR.velocity.z, 0.0, cR.moveDeccel * delta)
		
		if cR.hitGroundCooldown <= 0: 
			cR.desiredMoveSpeed = cR.velocity.length()
			
	if cR.desiredMoveSpeed >= cR.maxSpeed: 
		cR.desiredMoveSpeed = cR.maxSpeed
