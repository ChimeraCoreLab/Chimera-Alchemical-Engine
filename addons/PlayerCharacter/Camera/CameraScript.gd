extends Node3D
class_name CameraObject 
@export_group("Camera variables")
@export var XAxisSensibility : float
@export var YAxisSensibility : float
@export var maxUpAngleView : float
@export var maxDownAngleView : float
@export_group("FOV variables")
@export var startFOV : float
@export_group("Movement changes variables")
@export var baseCamAngle : float
@export var baseCameraLerpSpeed : float
@export var crouchCamAngle : float
@export var crouchCameraLerpSpeed : float
@export var crouchCameraDepth : float 
@export_group("Camera bob variables")
var headBobValue : float
@export var bobFrequency : float
@export var bobAmplitude : float
@export_group("Camera tilt variables")
@export var camTiltRotationValue : float 
@export var camTiltRotationSpeed : float
@export var onFloorTiltValDivider : float
@export_group("Mouse variables")
var mouseFree : bool = false
@export_group("Keybind variables")
@export var mouseModeAction : String = ""
@onready var camera : Camera3D = $Camera
@onready var playChar : PlayerCharacter =  $".."
@onready var hud : CanvasLayer = $"../HUD"
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.fov = startFOV
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * (XAxisSensibility / 10))
		camera.rotate_x(-event.relative.y * (YAxisSensibility / 10))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(maxUpAngleView), deg_to_rad(maxDownAngleView))
func _process(delta):
	applies(delta)
	cameraBob(delta)
	cameraTilt(delta)
	mouseMode()
func applies(delta : float):
	if playChar.stateMachine.currStateName == "Crouch":
		position.y = lerp(position.y, 0.715 + crouchCameraDepth, crouchCameraLerpSpeed * delta)
		rotation.z = lerp(rotation.z, deg_to_rad(crouchCamAngle) * playChar.inputDirection.x if playChar.inputDirection.x != 0.0 else deg_to_rad(crouchCamAngle), crouchCameraLerpSpeed * delta)
	else:
		position.y = lerp(position.y, 0.715, baseCameraLerpSpeed * delta)
		rotation.z = lerp(rotation.z, deg_to_rad(baseCamAngle), baseCameraLerpSpeed * delta)
func cameraBob(delta):
	headBobValue += delta * playChar.velocity.length() * float(playChar.is_on_floor())
	camera.transform.origin = headbob(headBobValue)
func headbob(time):
	var pos = Vector3.ZERO
	pos.y = sin(time * bobFrequency) * bobAmplitude
	pos.x = cos(time * bobFrequency / 4) * bobAmplitude
	return pos
func cameraTilt(delta): 
	if !playChar.is_on_floor(): rotation.z = lerp(rotation.z, -playChar.inputDirection.x * camTiltRotationValue/onFloorTiltValDivider, camTiltRotationSpeed * delta)
	else: rotation.z = lerp(rotation.z, -playChar.inputDirection.x * camTiltRotationValue, camTiltRotationSpeed * delta)
func mouseMode():
	if Input.is_action_just_pressed(mouseModeAction): mouseFree = !mouseFree
	if !mouseFree: Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
