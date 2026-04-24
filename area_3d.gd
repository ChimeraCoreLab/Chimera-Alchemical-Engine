extends Area3D

@export var target_door : MeshInstance3D 
@onready var sfx_player = AudioStreamPlayer.new()

var open_sfx = "/storage/emulated/0/Chimera_V4_Genesis/room_door_O.mp3"
var close_sfx = "/storage/emulated/0/Chimera_V4_Genesis/room_door_c.mp3"

var already = false


@onready var anim2 = $"../AnimationPlayer"
@onready var another_cam = $"../Camera3D"

func _ready() -> void:
	add_child(sfx_player)
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = 2
	
	body_entered.connect(_on_interaction)
	body_exited.connect(_on_closure)
	
	if target_door == null:
		print("[!] WARNING: target_door is empty!")

func _play_external_sfx(path: String) -> void:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var stream = AudioStreamMP3.new()
		stream.data = file.get_buffer(file.get_length())
		sfx_player.stream = stream
		sfx_player.play()

func _on_interaction(body: Node3D) -> void:
	if body.is_in_group("PlayerCharacter") or "Player" in body.name:
		print("[SIGNAL]: PLAYER_UPLINK")
		
		if target_door:
			var local_pos = target_door.to_local(body.global_position)
			var angle = 120.0 if local_pos.z < 0 else -120.0
			var tw = create_tween()
			tw.tween_property(target_door, "rotation:y", deg_to_rad(angle), 0.5).set_trans(Tween.TRANS_CUBIC)
		
		_play_external_sfx(open_sfx)
		

		if not already:
			already = true
			if anim2: anim2.play('new_animation_2')
			if another_cam: 
				another_cam.current = true

func _on_closure(body: Node3D) -> void:
	if body.is_in_group("PlayerCharacter") or "Player" in body.name:
		if target_door:
			var tw = create_tween()
			tw.tween_property(target_door, "rotation:y", 0.0, 0.6).set_trans(Tween.TRANS_SINE)
		
		_play_external_sfx(close_sfx)
		print("[SIGNAL]: DOOR_SECURED")
		

		var player_cam = get_node_or_null("/root/Main/CanvasLayer4/Player/CameraHolder/Camera")
		if player_cam:
			player_cam.current = true
			print("[SIGNAL]: RETURN_TO_PLAYER_POV")
		else:

			var cameras = get_tree().get_nodes_in_group("PlayerCharacter")
			if not cameras.is_empty():

				var cam = cameras[0].find_child("Camera", true, false)
				if cam: cam.current = true
