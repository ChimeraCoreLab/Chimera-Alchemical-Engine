extends RichTextLabel

func _ready() -> void:
	bbcode_enabled = true
	scroll_active = true
	scroll_following = false
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mouse_filter = Control.MOUSE_FILTER_IGNORE 
	custom_minimum_size.y = 280 

func apply_proxy_scroll(relative_y: float) -> void:
	var v_scroll = get_v_scroll_bar()
	if v_scroll:
		v_scroll.value -= relative_y
