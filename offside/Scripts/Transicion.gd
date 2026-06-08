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
	get_tree().paused= false
	color_rect.mouse_filter= Control.MOUSE_FILTER_STOP
	var tw= create_tween()
	tw.tween_property(color_rect, "color:a", 1.0, 0.3)
	await tw.finished
	get_tree().change_scene_to_file(ruta)
	await get_tree().process_frame
	var tw2= create_tween()
	tw2.tween_property(color_rect, "color:a", 0.0, 0.3)
	await tw2.finished
	color_rect.mouse_filter= Control.MOUSE_FILTER_IGNORE
	transicionando= false
