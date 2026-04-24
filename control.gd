extends Control
@export var sensitivity : float = 0.15
var player_character : CharacterBody3D
var cam_holder : Node3D
func _ready() -> void:
	player_character = get_tree().get_first_node_in_group("PlayerCharacter")
	if player_character:
		cam_holder = player_character.get_node("CameraHolder")
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_PASS 
func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if player_character and cam_holder:
			player_character.rotate_y(deg_to_rad(-event.relative.x * sensitivity))
			var change_x = -event.relative.y * sensitivity
			var current_rotation_x = rad_to_deg(cam_holder.rotation.x)
			if current_rotation_x + change_x > -89 and current_rotation_x + change_x < 89:
				cam_holder.rotate_x(deg_to_rad(change_x))
