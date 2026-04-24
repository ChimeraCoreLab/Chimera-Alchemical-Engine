class_name VirtualJoystick
extends Control

@export var pressed_color := Color.GRAY
@export_range(0, 200, 1) var deadzone_size : float = 10
@export_range(0, 500, 1) var clampzone_size : float = 75

enum Joystick_mode { FIXED, DYNAMIC, FOLLOWING }
@export var joystick_mode := Joystick_mode.FIXED

enum Visibility_mode { ALWAYS, TOUCHSCREEN_ONLY, WHEN_TOUCHED }
@export var visibility_mode := Visibility_mode.ALWAYS

@export var use_input_actions := true
@export var action_left := "moveLeft"
@export var action_right := "moveRight"
@export var action_up := "moveForward"
@export var action_down := "moveBackward"

var is_pressed := false
var output := Vector2.ZERO
var _touch_index : int = -1

@onready var _base := $Base
@onready var _tip := $Base/Tip
@onready var _base_default_position : Vector2 = _base.position
@onready var _tip_default_position : Vector2 = _tip.position
@onready var _default_color : Color = _tip.modulate

func _ready() -> void:
	if not DisplayServer.is_touchscreen_available() and visibility_mode == Visibility_mode.TOUCHSCREEN_ONLY:
		hide()
	if visibility_mode == Visibility_mode.WHEN_TOUCHED:
		hide()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if _is_point_inside_joystick_area(event.position) and _touch_index == -1:
				if joystick_mode == Joystick_mode.DYNAMIC or joystick_mode == Joystick_mode.FOLLOWING or (joystick_mode == Joystick_mode.FIXED and _is_point_inside_base(event.position)):
					if joystick_mode == Joystick_mode.DYNAMIC or joystick_mode == Joystick_mode.FOLLOWING:
						_move_base(event.position)
					if visibility_mode == Visibility_mode.WHEN_TOUCHED:
						show()
					_touch_index = event.index
					_tip.modulate = pressed_color
					_update_joystick(event.position)
					get_viewport().set_input_as_handled()
		elif event.index == _touch_index:
			_reset()
			if visibility_mode == Visibility_mode.WHEN_TOUCHED:
				hide()
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			_update_joystick(event.position)
			get_viewport().set_input_as_handled()

func _move_base(new_position: Vector2) -> void:
	_base.global_position = new_position - _base.pivot_offset * get_global_transform_with_canvas().get_scale()

func _move_tip(new_position: Vector2) -> void:
	_tip.global_position = new_position - _tip.pivot_offset * _base.get_global_transform_with_canvas().get_scale()

func _is_point_inside_joystick_area(point: Vector2) -> bool:
	var s = size * get_global_transform_with_canvas().get_scale()
	return Rect2(global_position, s).has_point(point)

func _is_point_inside_base(point: Vector2) -> bool:
	var radius = _base.size.x * get_global_transform_with_canvas().get_scale().x / 2
	return point.distance_to(_base.global_position + _base.size * get_global_transform_with_canvas().get_scale() / 2) <= radius

func _update_joystick(touch_position: Vector2) -> void:
	var base_center = _base.global_position + _base.size * get_global_transform_with_canvas().get_scale() / 2
	var vector = touch_position - base_center
	vector = vector.limit_length(clampzone_size)
	
	if joystick_mode == Joystick_mode.FOLLOWING and touch_position.distance_to(base_center) > clampzone_size:
		_move_base(touch_position - vector)
	
	_move_tip(base_center + vector)
	
	if vector.length() > deadzone_size:
		is_pressed = true
		output = (vector - (vector.normalized() * deadzone_size)) / (clampzone_size - deadzone_size)
	else:
		is_pressed = false
		output = Vector2.ZERO
	
	if use_input_actions:
		_handle_input_action(action_left, -output.x if output.x < 0 else 0.0)
		_handle_input_action(action_right, output.x if output.x > 0 else 0.0)
		_handle_input_action(action_up, -output.y if output.y < 0 else 0.0)
		_handle_input_action(action_down, output.y if output.y > 0 else 0.0)

func _handle_input_action(action: String, strength: float) -> void:
	if strength > 0:
		Input.action_press(action, strength)
	else:
		Input.action_release(action)

func _reset():
	is_pressed = false
	output = Vector2.ZERO
	_touch_index = -1
	_tip.modulate = _default_color
	_base.position = _base_default_position
	_tip.position = _tip_default_position
	if use_input_actions:
		for a in [action_left, action_right, action_up, action_down]:
			Input.action_release(a)
