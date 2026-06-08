extends CanvasLayer

var color_rect: ColorRect
var transicionando: bool= false
var _ruta_pendiente: String= ""

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
	_ruta_pendiente= ruta
	get_tree().paused= false
	color_rect.mouse_filter= Control.MOUSE_FILTER_STOP
	var tw= create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(color_rect, "color:a", 1.0, 0.3)
	tw.finished.connect(_on_fade_out_terminado)

func _on_fade_out_terminado() -> void:
	get_tree().change_scene_to_file(_ruta_pendiente)
	get_tree().create_timer(0.1).timeout.connect(_on_escena_lista)

func _on_escena_lista() -> void:
	var tw= create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(color_rect, "color:a", 0.0, 0.3)
	tw.finished.connect(_on_fade_in_terminado)

func _on_fade_in_terminado() -> void:
	color_rect.mouse_filter= Control.MOUSE_FILTER_IGNORE
	transicionando= false
