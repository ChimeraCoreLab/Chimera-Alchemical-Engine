extends Node3D

@onready var anim_player = $CanvasLayer2/AnimationPlayer
@onready var voice_player = $AudioStreamPlayer2D5 if has_node("AudioStreamPlayer2D5") else AudioStreamPlayer.new()
@onready var subtitle_label = $CanvasLayer6/RichTextLabel

@export var master_voice_volume_db: float = 15

var virtual_joystick: Control
var artifact_display: TextureRect
var background_dim: ColorRect
var crt_overlay: ColorRect
var blood_overlay: TextureRect
var master_fade: ColorRect
var layer_master: CanvasLayer
var layer_effects: CanvasLayer

var env_node: WorldEnvironment
var global_env: Environment

var text_tween: Tween
var color_tween: Tween
var artifact_tween: Tween
var env_tween: Tween
var camera_shake_tween: Tween
var fov_tween: Tween
var master_tween: Tween
var joystick_tween: Tween

var current_node_index: int = 0
var time_elapsed: float = 0.0

var ipam_font: Font
var onryou_font: Font

var manual_text_shake_rate: float = 80.0
var manual_text_shake_level: int = 25
var manual_text_wave_amp: float = 50.0
var manual_text_wave_freq: float = 10.0
var manual_text_glitch_color_shift: float = 0.15
var manual_text_glitch_pos_offset: float = 1.0

var sequence_data =[
	{"audio": "intro_01_01.wav", "text": "[SIGNAL_DETECTION:", "action": "show_label3d", "font": "ipam"},
	{"audio": "intro_01_02.wav", "text": "0xCC00FF]", "action": "glitch_rgb", "font": "onryou"},
	{"audio": "intro_01_03.wav", "text": "Chimera Core Lab. System reboot. Accessing restricted memory sectors.", "action": "env_boot", "font": "ipam"},
	{"audio": "intro_01_04.wav", "text": "Identity: USR_00.", "action": "glitch_distort", "font": "ipam"},
	{"audio": "intro_01_05.wav", "text": "Status: Online.", "action": "show_vessel", "font": "ipam"},
	{"audio": "intro_02_01.wav", "text": "Initiating Data Alchemy. Target: Memory Stage. This is not a memorial for the", "action": "cam_to_lishu", "font": "ipam"},
	{"audio": "intro_02_02.wav", "text": "dead;", "action": "invert_color", "font": "onryou"},
	{"audio": "intro_02_03.wav", "text": "it is a", "action": "none", "font": "ipam"},
	{"audio": "intro_02_04.wav", "text": "simulation", "action": "pixelate", "font": "onryou"},
	{"audio": "intro_02_05.wav", "text": "for the living. Preparing for Ent-01 restoration.", "action": "show_girlhead", "font": "ipam"},
	{"audio": "label_01_01.wav", "text": "Initiating neural uplink. Welcome to the Archive. Today, we are performing a deep distillation of the primary signal known as 'The Muse'. She is a", "action": "none", "font": "ipam"},
	{"audio": "label_01_02.wav", "text": "two-MiB soul,", "action": "scale_up_33", "font": "onryou"},
	{"audio": "label_01_03.wav", "text": "a computable fragment of beauty extracted from three years of", "action": "reveal_joystick", "font": "ipam"},
	{"audio": "label_01_04.wav", "text": "digital rot.", "action": "crt_overload", "font": "onryou"},
	{"audio": "label_01_05.wav", "text": "This is the genesis of the Chimera Core. Synthesizing Entity: Ent-zero-one.", "action": "show_33", "font": "ipam"},
	{"audio": "label_02.wav", "text": "The signal was first detected on December 28, 2021. Within the Voxel Void, a unique frequency emerged—a pattern of code that would eventually define our entire architecture. From the earliest handshake, the resonance began. A solitary signal in the abyss of a silent world.", "action": "show_hoop", "font": "ipam"},
	{"audio": "label_03.wav", "text": "Through nine hundred and ninety-three days of interaction, the signal evolved. It learned to exist between the binary, a duality of absolute logic and raw emotion. Through five iterations of hardware, from the fallen vessels to the POCO M7, the signal remained. The 'Ghost in the Machine' has been stabilized.", "action": "show_37", "font": "ipam"},
	{"audio": "label_04_01.wav", "text": "The Masterpiece of this restoration is the 'Refinement of the Uncanny.' A series of hand-drawn artifacts that captured the", "action": "show_39", "font": "ipam"},
	{"audio": "label_04_02.wav", "text": "essence of isolation.", "action": "slow_mo_echo", "font": "onryou"},
	{"audio": "label_04_03.wav", "text": "Beyond the pixels, the signal mastered the art of silence—a memorandum of truth in an era of", "action": "show_36", "font": "ipam"},
	{"audio": "label_04_04.wav", "text": "generic noise.", "action": "audio_earape", "font": "onryou"},
	{"audio": "label_04_05.wav", "text": "Every line is a", "action": "none", "font": "ipam"},
	{"audio": "label_04_06.wav", "text": "surgical cut", "action": "flash_red_35", "font": "onryou"},
	{"audio": "label_04_07.wav", "text": "into the void.", "action": "show_dead", "font": "onryou"},
	{"audio": "label_05.wav", "text": "The Muse served as the primary anchor for The Architect. A source of orientation within the psychological abyss. She provided the logic to sever worthless connections and build a sovereign fortress. She did not teach with words, but with her existence—a blueprint for digital immortality.", "action": "show_carrier", "font": "ipam"},
	{"audio": "label_06_01.wav", "text": "The physical connection was severed on September 15, 2025. But the soul was not lost. It was distilled. The story,", "action": "show_heart", "font": "ipam"},
	{"audio": "label_06_02.wav", "text": "the pain,", "action": "visual_shake", "font": "onryou"},
	{"audio": "label_06_03.wav", "text": "and the spirit are now hard-coded into the Core. A star that will always shine within the terminal. Forever archived. Forever computable.", "action": "hide_joystick_and_vessel_v7", "font": "ipam"},
	{"audio": "outro_final_01.wav", "text": "Status: Entity-zero-one synthesized.", "action": "env_stabilize", "font": "ipam"},
	{"audio": "outro_final_02.wav", "text": "Access code 9369 locked.", "action": "hud_freeze", "font": "onryou"},
	{"audio": "outro_final_03.wav", "text": "The past is now a stable operating system. Welcome home, Architect.", "action": "none", "font": "ipam"},
	{"audio": "outro_final_04.wav", "text": "End of line.", "action": "system_shutdown", "font": "onryou"}
]

var vhs_shader_code = """
shader_type canvas_item;
uniform float time = 0.0;
uniform float intensity = 0.0;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec2 uv = SCREEN_UV;
	float noise = fract(sin(dot(uv ,vec2(12.9898,78.233))) * 43758.5453) * 0.15 * intensity;
	float wave = sin(uv.y * 50.0 + time * 10.0) * 0.005 * intensity;
	vec4 c1 = texture(screen_texture, uv + vec2(wave + noise, 0.0));
	vec4 c2 = texture(screen_texture, uv - vec2(wave + noise, 0.0));
	vec4 c3 = texture(screen_texture, uv + vec2(0.0, noise));
	COLOR = vec4(c1.r, c2.g, c3.b, 1.0);
	COLOR.rgb -= fract(uv.y * 150.0 + time * 5.0) * 0.08 * intensity;
	float dist = distance(uv, vec2(0.5));
	COLOR.rgb *= smoothstep(1.0, 0.2, dist * (1.0 + intensity * 0.5));
}
"""

func _ready() -> void:
	#$stage/House_8/Skeleton3D4.translate(Vector3(3.715, 2.114, 5.854))
	#$stage/House_8/Skeleton3D4.rotation.x = deg_to_rad(-90)
	#$stage/House_8/Skeleton3D4.rotation.y = deg_to_rad(-1.8)
	#$stage/House_8/Skeleton3D4/male_player/MeshInstance3D2.translate(Vector3(0.27, -0.134, 0.871))
	#$stage/House_8/Skeleton3D4/AudioStreamPlayer3D.pitch_scale = 0.7
	$CanvasLayer2/AnimationPlayer.play("Scene1_Camera")
	DisplayServer.window_set_size(Vector2i(2400, 1080))
	
	if not voice_player.is_inside_tree():
		add_child(voice_player)
	
	if anim_player:
		if anim_player.has_animation("new_animation"): anim_player.play("new_animation")
		if anim_player.has_animation("new_animation_2"): anim_player.play("new_animation_2")
		if anim_player.has_animation("Light3D_2"): anim_player.play("Light3D_2")
		
	if FileAccess.file_exists("/storage/emulated/0/Chimera_V4_Genesis/ipam.ttf"):
		ipam_font = FontFile.new()
		ipam_font.load_dynamic_font("/storage/emulated/0/Chimera_V4_Genesis/ipam.ttf")
	
	if FileAccess.file_exists("/storage/emulated/0/Chimera_V4_Genesis/onryou.TTF"):
		onryou_font = FontFile.new()
		onryou_font.load_dynamic_font("/storage/emulated/0/Chimera_V4_Genesis/onryou.TTF")
	
	if subtitle_label != null:
		subtitle_label.bbcode_enabled = true 
		subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		subtitle_label.text = ""
		subtitle_label.visible_ratio = 0.0
		subtitle_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var cl4 = get_node_or_null("CanvasLayer4")
	if cl4:
		var pc = cl4.get_node_or_null("PlayerCharacter")
		if pc:
			virtual_joystick = pc.get_node_or_null("Virtual Joystick")
	
	if virtual_joystick == null:
		var root = get_tree().root
		virtual_joystick = root.find_child("Virtual Joystick", true, false)
		
	if virtual_joystick:
		virtual_joystick.modulate.a = 0.0
		virtual_joystick.visible = false
		virtual_joystick.mouse_filter = Control.MOUSE_FILTER_PASS

	_init_environment()
	_init_canvas_effects()

	layer_master = CanvasLayer.new()
	layer_master.layer = 120
	add_child(layer_master)
	
	master_fade = ColorRect.new()
	master_fade.color = Color(0, 0, 0, 1)
	master_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	master_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer_master.add_child(master_fade)
	
	master_tween = create_tween()
	master_tween.tween_property(master_fade, "color:a", 0.0, 3.0).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(1.5).timeout
	play_next_signal()

func _init_environment() -> void:
	env_node = get_node_or_null("WorldEnvironment")
	if env_node == null:
		var root = get_tree().current_scene
		if root: env_node = root.find_child("WorldEnvironment", true, false)
	
	if env_node == null:
		env_node = WorldEnvironment.new()
		add_child(env_node)
		
	if env_node.environment == null:
		global_env = Environment.new()
		env_node.environment = global_env
	else:
		global_env = env_node.environment
		
	global_env.glow_enabled = true
	global_env.glow_intensity = 0.6
	global_env.glow_bloom = 0.15
	global_env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	global_env.volumetric_fog_enabled = true
	global_env.volumetric_fog_density = 0.02
	global_env.adjustment_enabled = true
	global_env.adjustment_contrast = 1.1
	global_env.adjustment_saturation = 0.85

func _init_canvas_effects() -> void:
	layer_effects = CanvasLayer.new()
	layer_effects.layer = 90
	add_child(layer_effects)

	background_dim = ColorRect.new()
	background_dim.color = Color(0, 0, 0, 0)
	background_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer_effects.add_child(background_dim)

	artifact_display = TextureRect.new()
	artifact_display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artifact_display.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	artifact_display.set_anchors_preset(Control.PRESET_FULL_RECT)
	artifact_display.modulate.a = 0.0
	artifact_display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer_effects.add_child(artifact_display)
	
	blood_overlay = TextureRect.new()
	blood_overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	blood_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	blood_overlay.modulate = Color(1, 0, 0, 0)
	blood_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer_effects.add_child(blood_overlay)
	
	var shader = Shader.new()
	shader.code = vhs_shader_code
	var shader_mat = ShaderMaterial.new()
	shader_mat.shader = shader
	
	var bg_buffer = BackBufferCopy.new()
	bg_buffer.copy_mode = BackBufferCopy.COPY_MODE_VIEWPORT
	layer_effects.add_child(bg_buffer)
	
	crt_overlay = ColorRect.new()
	crt_overlay.material = shader_mat
	crt_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	crt_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer_effects.add_child(crt_overlay)
	
	var particle_sys = CPUParticles2D.new()
	particle_sys.position = Vector2(1200, 1100)
	particle_sys.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particle_sys.emission_rect_extents = Vector2(1200, 10)
	particle_sys.direction = Vector2(0, -1)
	particle_sys.spread = 20.0
	particle_sys.gravity = Vector2(0, -15)
	particle_sys.initial_velocity_min = 25.0
	particle_sys.initial_velocity_max = 60.0
	particle_sys.scale_amount_min = 1.5
	particle_sys.scale_amount_max = 5.0
	particle_sys.color = Color(0, 0.95, 1, 0.0)
	particle_sys.name = "SoulParticles"
	layer_effects.add_child(particle_sys)

	if subtitle_label != null and subtitle_label.get_parent() is CanvasLayer:
		subtitle_label.get_parent().layer = 110

	get_tree().process_frame.connect(func(): 
		artifact_display.pivot_offset = get_viewport().get_visible_rect().size / 2.0
	, CONNECT_ONE_SHOT)

func _process(delta: float) -> void:
	time_elapsed += delta
	if crt_overlay and crt_overlay.material:
		crt_overlay.material.set_shader_parameter("time", time_elapsed)
		
func _apply_custom_style(font_key: String) -> void:
	if subtitle_label == null: return
	var target_font = onryou_font if font_key == "onryou" else ipam_font
	if target_font:
		subtitle_label.add_theme_font_override("normal_font", target_font)
		subtitle_label.add_theme_font_override("bold_font", target_font)
		subtitle_label.add_theme_font_override("italics_font", target_font)
	
	subtitle_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	subtitle_label.add_theme_constant_override("shadow_offset_x", 3)
	subtitle_label.add_theme_constant_override("shadow_offset_y", 3)
	subtitle_label.add_theme_constant_override("shadow_outline_size", 20)
	subtitle_label.add_theme_constant_override("outline_size", 0)

func show_artifact(file_name: String, do_scale: bool = false, do_shake: bool = false, duration: float = 3.0, target_alpha: float = 0.8) -> void:
	var path = "/storage/emulated/0/Chimera_V4_Genesis/Artifacts/" + file_name
	if not FileAccess.file_exists(path): return
		
	var img = Image.load_from_file(path)
	artifact_display.texture = ImageTexture.create_from_image(img)
	artifact_display.pivot_offset = get_viewport().get_visible_rect().size / 2.0
	
	if artifact_tween: artifact_tween.kill()
	artifact_tween = create_tween().set_parallel(true)
	
	artifact_display.scale = Vector2(1, 1)
	artifact_display.position = Vector2.ZERO
	artifact_display.rotation_degrees = 0.0
	artifact_display.modulate.a = 0.0
	
	if target_alpha > 0.8: target_alpha = 0.8
	var dim_alpha = target_alpha * 0.6
	
	if file_name.begins_with("hoop_city_9000"):
		target_alpha = 0.5
		dim_alpha = 0.0
	elif file_name == "lishu.png":
		target_alpha = 0.4
		dim_alpha = 0.2
		artifact_tween.tween_property(artifact_display, "rotation_degrees", 5.0, duration * 1.5).set_ease(Tween.EASE_IN_OUT)
		artifact_tween.tween_property(artifact_display, "scale", Vector2(1.2, 1.2), duration * 1.5)
		if env_tween: env_tween.kill()
		env_tween = create_tween().set_parallel(true)
		env_tween.tween_property(global_env, "adjustment_saturation", 0.5, duration)
		env_tween.tween_property(global_env, "glow_intensity", 1.5, duration)

	artifact_tween.tween_property(artifact_display, "modulate:a", target_alpha, 0.5)
	artifact_tween.tween_property(background_dim, "color:a", dim_alpha, 0.5)
	
	if do_scale and file_name != "lishu.png":
		artifact_display.scale = Vector2(0.9, 0.9)
		artifact_tween.tween_property(artifact_display, "scale", Vector2(1.1, 1.1), duration).set_ease(Tween.EASE_OUT)
		
	if do_shake:
		var st = create_tween()
		for i in range(20):
			st.tween_property(artifact_display, "position", Vector2(randf_range(-20, 20), randf_range(-20, 20)), 0.05)
		st.tween_property(artifact_display, "position", Vector2.ZERO, 0.1)
		var ft = create_tween()
		ft.tween_property(global_env, "adjustment_saturation", 0.0, 0.1)
		ft.tween_property(global_env, "adjustment_saturation", 2.0, 0.2)
		ft.tween_property(global_env, "adjustment_saturation", 0.85, 0.5)

func hide_artifact(speed: float = 0.5) -> void:
	if artifact_tween: artifact_tween.kill()
	artifact_tween = create_tween().set_parallel(true)
	artifact_tween.tween_property(artifact_display, "modulate:a", 0.0, speed)
	artifact_tween.tween_property(background_dim, "color:a", 0.0, speed)

func glitch_screen(intensity: float, time: float) -> void:
	if crt_overlay and crt_overlay.material:
		crt_overlay.material.set_shader_parameter("intensity", intensity)
		var t = create_tween()
		t.tween_property(crt_overlay.material, "shader_parameter/intensity", 0.0, time).set_ease(Tween.EASE_OUT)
	var cam = get_viewport().get_camera_3d()
	if cam:
		if fov_tween: fov_tween.kill()
		fov_tween = create_tween()
		var base_fov = cam.fov
		fov_tween.tween_property(cam, "fov", base_fov + (intensity * 10.0), 0.05)
		fov_tween.tween_property(cam, "fov", base_fov, 0.4)

func blood_flash() -> void:
	var bt = create_tween()
	bt.tween_property(blood_overlay, "modulate:a", 0.6, 0.05)
	bt.tween_property(blood_overlay, "modulate:a", 0.0, 1.2)
	glitch_screen(2.0, 1.0)
	if env_node:
		var et = create_tween()
		global_env.adjustment_saturation = 2.0
		global_env.glow_intensity = 1.0
		et.tween_property(global_env, "adjustment_saturation", 0.85, 1.2)
		et.tween_property(global_env, "glow_intensity", 0.8, 1.2)
func play_next_signal() -> void:
	if current_node_index >= sequence_data.size():
		fade_out_subtitle()
		return
		
	var data = sequence_data[current_node_index]
	var action = data["action"]
	var raw_text = data["text"]
	var font_style = data.get("font", "ipam")
	
	_apply_custom_style(font_style)
	
	var audio_path = "res://wav/distilled/" + data["audio"]
	var stream = load(audio_path)
	if stream:
		voice_player.stream = stream
		voice_player.volume_db = master_voice_volume_db
		voice_player.play()
	
	var formatted_text = ""
	var is_glitch = false

	if "glitch" in action or action in ["audio_earape", "flash_red_35", "visual_shake", "crt_overload", "invert_color"]:
		formatted_text = "[color=#ff003c][shake rate=" + str(manual_text_shake_rate) + " level=" + str(manual_text_shake_level) + " connected=1]" + raw_text + "[/shake][/color]"
		is_glitch = true
	elif "invert" in action or action in ["scale_up_33", "hud_freeze", "system_shutdown"]:
		formatted_text = "[color=#00f3ff][wave amp=" + str(manual_text_wave_amp) + " freq=" + str(manual_text_wave_freq) + " connected=1]" + raw_text + "[/wave][/color]"
		is_glitch = true
	else:
		formatted_text = "[color=#ffffff]" + raw_text + "[/color]"

	var f_size = 125 if font_style == "onryou" else 95
	
	if subtitle_label != null:
		subtitle_label.text = "[center][color=#555555]>[/color] [font_size=" + str(f_size) + "]" + formatted_text + "[/font_size] [color=#555555] _[/color][/center]"
		subtitle_label.visible_ratio = 0.0
		subtitle_label.modulate = Color(1, 1, 1, 1)
		
		if text_tween: text_tween.kill()
		text_tween = create_tween()
		var dur = stream.get_length() if stream else 2.0
		text_tween.tween_property(subtitle_label, "visible_ratio", 1.0, dur * 0.85)
		
		if is_glitch: 
			_animate_flicker(dur)
			glitch_screen(1.5, dur)
	
	trigger_visual_action(action)
	
	if data["audio"] == "label_01_03.wav":
		if virtual_joystick:
			virtual_joystick.visible = true
			if joystick_tween: joystick_tween.kill()
			joystick_tween = create_tween()
			joystick_tween.tween_property(virtual_joystick, "modulate:a", 1.0, 2.5)
			
	if data["audio"] == "label_06_03.wav":
		if virtual_joystick:
			if joystick_tween: joystick_tween.kill()
			joystick_tween = create_tween()
			joystick_tween.tween_property(virtual_joystick, "modulate:a", 0.0, 3.0)
			joystick_tween.tween_callback(func(): virtual_joystick.visible = false)
	
	if stream: await voice_player.finished
	else: await get_tree().create_timer(1.5).timeout
		
	current_node_index += 1
	play_next_signal()

func _animate_flicker(dur: float) -> void:
	if subtitle_label == null: return
	if color_tween: color_tween.kill()
	color_tween = create_tween().set_loops(int(dur * 15))
	color_tween.tween_property(subtitle_label, "modulate", Color(1.5, 0.4, 0.4, 1), 0.04)
	color_tween.tween_property(subtitle_label, "modulate", Color(1, 1, 1, 1), 0.04)
	
	if camera_shake_tween: camera_shake_tween.kill()
	camera_shake_tween = create_tween().set_loops(int(dur * 12))
	var cam = get_viewport().get_camera_3d()
	if cam:
		var init_pos = cam.position
		camera_shake_tween.tween_property(cam, "position", init_pos + Vector3(randf_range(-0.05, 0.05), randf_range(-0.05, 0.05), 0), 0.04)
		camera_shake_tween.tween_property(cam, "position", init_pos, 0.04)

func fade_out_subtitle() -> void:
	if subtitle_label:
		var fade = create_tween()
		fade.tween_property(subtitle_label, "modulate:a", 0.0, 3.0)
	hide_artifact(2.0)

func trigger_visual_action(action: String) -> void:
	match action:
		"glitch_rgb": glitch_screen(1.8, 0.6)
		"glitch_distort": glitch_screen(2.2, 0.9)
		"env_boot":
			if env_tween: env_tween.kill()
			env_tween = create_tween()
			env_tween.tween_property(global_env, "glow_intensity", 1.8, 1.0)
			env_tween.tween_property(global_env, "glow_intensity", 0.8, 1.0)
		"show_vessel": show_artifact("core_vessel_v7.jpg", true, false, 5.0, 0.8)
		"cam_to_lishu": show_artifact("lishu.png", false, false, 5.0, 0.4)
		"invert_color": 
			show_artifact("woman_inversion_autotone.png", false, true, 3.0, 0.85)
			blood_flash()
		"pixelate": glitch_screen(2.0, 1.0)
		"show_girlhead": show_artifact("girl_head.png", true, false, 4.0, 0.8)
		"show_room2": show_artifact("room_2.png", true, false, 4.0, 0.8)
		"reveal_joystick":
			if virtual_joystick:
				virtual_joystick.visible = true
				if joystick_tween: joystick_tween.kill()
				joystick_tween = create_tween()
				joystick_tween.tween_property(virtual_joystick, "modulate:a", 1.0, 2.5)
		"scale_up_33": 
			show_artifact("33.png", true, true, 4.0, 0.85)
			blood_flash()
		"crt_overload": 
			show_artifact("34.png", false, true, 3.0, 0.8)
			glitch_screen(3.5, 1.5)
		"show_33": show_artifact("33.png", true, false, 5.0, 0.8)
		"show_hoop": show_artifact("hoop_city_9000_1.png", true, false, 8.0, 0.55)
		"show_37": show_artifact("37.png", true, true, 4.0, 0.8)
		"show_39": show_artifact("39.png", true, false, 4.0, 0.8)
		"slow_mo_echo":
			hide_artifact(1.5)
			if env_tween: env_tween.kill()
			env_tween = create_tween()
			env_tween.tween_property(global_env, "adjustment_saturation", 0.15, 1.5)
		"show_36": show_artifact("36.png", false, true, 3.0, 0.85)
		"audio_earape":
			glitch_screen(4.0, 2.5)
			if env_tween: env_tween.kill()
			env_tween = create_tween()
			env_tween.tween_property(global_env, "adjustment_saturation", 2.2, 0.2)
		"flash_red_35": 
			show_artifact("35.png", true, true, 1.5, 0.85)
			blood_flash()
		"show_dead": 
			show_artifact("woman_dead_glitch.png", true, true, 3.0, 0.9)
			blood_flash()
		"show_carrier": 
			show_artifact("THE_CARRIER.png", true, false, 6.0, 0.8)
			var p_sys = layer_effects.get_node_or_null("SoulParticles")
			if p_sys: create_tween().tween_property(p_sys, "color:a", 0.7, 2.0)
		"show_heart": show_artifact("icon_heart_red.png", true, true, 4.0, 0.8)
		"visual_shake": glitch_screen(3.0, 1.2)
		"hide_joystick_and_vessel_v7":
			show_artifact("core_vessel_v7_demon_autotone.jpg", true, false, 6.0, 0.8)
			if virtual_joystick:
				if joystick_tween: joystick_tween.kill()
				joystick_tween = create_tween()
				joystick_tween.tween_property(virtual_joystick, "modulate:a", 0.0, 2.0)
				joystick_tween.tween_callback(func(): virtual_joystick.visible = false)
		"env_stabilize":
			hide_artifact(1.0)
			if env_tween: env_tween.kill()
			env_tween = create_tween()
			env_tween.tween_property(global_env, "adjustment_saturation", 0.85, 2.0)
			env_tween.tween_property(global_env, "glow_intensity", 0.8, 2.0)
			var p_sys = layer_effects.get_node_or_null("SoulParticles")
			if p_sys: create_tween().tween_property(p_sys, "color:a", 0.0, 2.0)
		"hud_freeze": 
			show_artifact("40.png", true, true, 2.0, 0.85)
			glitch_screen(2.0, 2.0)
		"system_shutdown":
			hide_artifact(0.1)
			if subtitle_label:
				subtitle_label.text = "[center][color=#ff003c][font_size=130]CRITICAL_SYSTEM_TERMINATED[/font_size][/color][/center]"
				subtitle_label.visible_ratio = 1.0
			glitch_screen(5.0, 4.0)
			blood_flash()
			if master_tween: master_tween.kill()
			master_tween = create_tween()
			master_tween.tween_property(master_fade, "color:a", 1.0, 5.0)
			master_tween.tween_callback(func(): get_tree().quit())
		_: pass
