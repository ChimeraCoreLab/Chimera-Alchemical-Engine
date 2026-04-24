extends Area3D
@export var target_door : MeshInstance3D 
@onready var sfx_player = AudioStreamPlayer.new()
var open_sfx = "/storage/emulated/0/Chimera_V4_Genesis/room_door_O.mp3"
var close_sfx = "/storage/emulated/0/Chimera_V4_Genesis/room_door_c.mp3"

var alreadyy = false

func _ready() -> void:
	add_child(sfx_player)
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = 2
	body_entered.connect(_on_interaction)
	body_exited.connect(_on_closure)
	if target_door == null:
		print("[!] WARNING: target_door is empty! Please assign it in Inspector.")
func _play_external_sfx(path: String) -> void:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var stream = AudioStreamMP3.new()
		stream.data = file.get_buffer(file.get_length())
		sfx_player.stream = stream
		sfx_player.play()
		print("[SONIC]: PLAYING -> ", path.get_file())
func _on_interaction(body: Node3D) -> void:
	if body is CharacterBody3D or body.is_in_group("PlayerCharacter") or "Player" in body.name:
		print("[SIGNAL]: PLAYER_DETECTED -> ", body.name)
		if target_door == null: return
		var local_pos = target_door.to_local(body.global_position)
		var angle = 120.0 if local_pos.z < 0 else -120.0
		var tw = create_tween()
		tw.tween_property(target_door, "rotation:y", deg_to_rad(angle), 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		_play_external_sfx(open_sfx)
		if not alreadyy:
			alreadyy = true
			$"../Skeleton3D4/AnimationPlayer".play("itcu")
			$"../Skeleton3D3/male_player/MeshInstance3D2/MeshInstance3D/AudioStreamPlayer3D".play()
			$"../Skeleton3D4/male_player/MeshInstance3D2".translate(Vector3(0, 500, 0))
			$"../Skeleton3D4".rotation.y = deg_to_rad(214.4)
			$"../Skeleton3D4/AudioStreamPlayer3D".pitch_scale = 0.3
			$"../Skeleton3D4/Label3D".show()
		
func _on_closure(body: Node3D) -> void:
	if body is CharacterBody3D or body.is_in_group("PlayerCharacter") or "Player" in body.name:
		if target_door == null: return
		var tw = create_tween()
		tw.tween_property(target_door, "rotation:y", 0.0, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_play_external_sfx(close_sfx)
		print("[SIGNAL]: DOOR_SECURED")
		
