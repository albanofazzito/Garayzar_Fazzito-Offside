extends CanvasLayer

var color_rect: ColorRect
var transicionando: bool= false

func _ready() -> void:
	layer= 100
	process_mode= Node.PROCESS_MODE_ALWAYS
	color_rect= ColorRect.new()
	color_rect.color= Color(0, 0, 0, 0)
	color_rect.anchors_preset= Control.PRESET_FULL_RECT
	color_rect.anchor_right= 1.0
	color_rect.anchor_bottom= 1.0
	color_rect.mouse_filter= Control.MOUSE_FILTER_IGNORE
	add_child(color_rect)

func cambiar_escena(ruta: String) -> void:
	if transicionando:
		return
	transicionando= true
	color_rect.mouse_filter= Control.MOUSE_FILTER_STOP
	var tw= create_tween()
	tw.tween_property(color_rect, "color:a", 1.0, 0.3)
	tw.tween_callback(func():
		get_tree().change_scene_to_file(ruta)
		_fade_in_despues.call_deferred()
	)

func _fade_in_despues() -> void:
	var tw2= create_tween()
	tw2.tween_property(color_rect, "color:a", 0.0, 0.3)
	tw2.tween_callback(func():
		color_rect.mouse_filter= Control.MOUSE_FILTER_IGNORE
		transicionando= false
	)
