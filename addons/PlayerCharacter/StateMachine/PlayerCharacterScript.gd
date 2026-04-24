extends CharacterBody3D

class_name PlayerCharacter 

@export_group("Movement variables")
var moveSpeed : float
var moveAccel : float
var moveDeccel : float
var desiredMoveSpeed : float 
@export var desiredMoveSpeedCurve : Curve
@export var maxSpeed : float = 30.0
@export var inAirMoveSpeedCurve : Curve
var inputDirection : Vector2 
var moveDirection : Vector3 
@export var hitGroundCooldown : float = 0.2
var hitGroundCooldownRef : float 
@export var bunnyHopDmsIncre : float = 3.0
@export var autoBunnyHop : bool = false
var lastFramePosition : Vector3 
var lastFrameVelocity : Vector3
var wasOnFloor : bool
var walkOrRun : String = "WalkState"

@export var baseHitboxHeight : float = 2.0
@export var baseModelHeight : float = 1.0
@export var heightChangeSpeed : float = 10.0

@export_group("Crouch variables")
@export var crouchSpeed : float = 5.0
@export var crouchAccel : float = 7.0
@export var crouchDeccel : float = 7.0
@export var continiousCrouch : bool = false
@export var crouchHitboxHeight : float = 1.2
@export var crouchModelHeight : float = 0.6

@export_group("Walk variables")
@export var walkSpeed : float = 8.0
@export var walkAccel : float = 8.0
@export var walkDeccel : float = 8.0

@export_group("Run variables")
@export var runSpeed : float = 12.0
@export var runAccel : float = 5.0
@export var runDeccel : float = 5.0
@export var continiousRun : bool = false

@export_group("Jump variables")
@export var jumpHeight : float = 2.0
@export var jumpTimeToPeak : float = 0.3
@export var jumpTimeToFall : float = 0.24
@onready var jumpVelocity : float = (2.0 * jumpHeight) / jumpTimeToPeak
@export var jumpCooldown : float = 0.2
var jumpCooldownRef : float 
@export var nbJumpsInAirAllowed : int = 1
var nbJumpsInAirAllowedRef : int 
var jumpBuffOn : bool = false
var bufferedJump : bool = false
@export var coyoteJumpCooldown : float = 0.3
var coyoteJumpCooldownRef : float
var coyoteJumpOn : bool = false

@export_group("Gravity variables")
@onready var jumpGravity : float = (-2.0 * jumpHeight) / (jumpTimeToPeak * jumpTimeToPeak)
@onready var fallGravity : float = (-2.0 * jumpHeight) / (jumpTimeToFall * jumpTimeToFall)

@export_group("Keybind variables")
@export var moveForwardAction : String = "moveForward"
@export var moveBackwardAction : String = "moveBackward"
@export var moveLeftAction : String = "moveLeft"
@export var moveRightAction : String = "moveRight"
@export var runAction : String = "run"
@export var crouchAction : String = "crouch"
@export var jumpAction : String = "jump"

@onready var camHolder : Node3D = $CameraHolder
@onready var model : MeshInstance3D = $Model
@onready var hitbox : CollisionShape3D = $Hitbox
@onready var stateMachine : Node = $StateMachine
@onready var hud : CanvasLayer = $HUD
@onready var ceilingCheck : RayCast3D = $Raycasts/CeilingCheck
@onready var floorCheck : RayCast3D = $Raycasts/FloorCheck
var joystick_node : VirtualJoystick

func _ready():
	moveSpeed = walkSpeed
	moveAccel = walkAccel
	moveDeccel = walkDeccel
	hitGroundCooldownRef = hitGroundCooldown
	jumpCooldownRef = jumpCooldown
	nbJumpsInAirAllowedRef = nbJumpsInAirAllowed
	coyoteJumpCooldownRef = coyoteJumpCooldown

	var root = get_tree().root

	var found = root.find_child("Virtual Joystick", true, false)
	if found:
		joystick_node = found
		print("[SYSTEM]: JOYSTICK_UPLINK_STABLE")
	
	var cam = camHolder.get_node("Camera")
	if cam:
		cam.make_current()

func _process(_delta: float):
	displayProperties()
	
func _physics_process(_delta : float):
	modifyPhysicsProperties()
	move_and_slide()
	
func displayProperties():
	if hud != null and stateMachine != null:
		hud.displayCurrentState(stateMachine.currStateName)
		hud.displayDesiredMoveSpeed(desiredMoveSpeed)
		hud.displayVelocity(velocity.length())
		hud.displayNbJumpsInAirAllowed(nbJumpsInAirAllowed)
		
func modifyPhysicsProperties():
	lastFramePosition = position
	lastFrameVelocity = velocity
	wasOnFloor = is_on_floor()
	
func gravityApply(delta : float):
	if velocity.y >= 0.0: velocity.y += jumpGravity * delta
	elif velocity.y < 0.0: velocity.y += fallGravity * delta
