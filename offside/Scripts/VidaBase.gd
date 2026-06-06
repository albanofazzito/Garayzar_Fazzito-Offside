class_name VidaBase
extends Panel

signal vida_agotada

const VIDA_MAX :=1000
var vida_actual :=200
var inmune: bool= false

@onready var label :Label= $Label
@onready var ladrillos :Sprite2D= $Ladrillos

func _ready() -> void:
	vida_actual =VIDA_MAX
	ladrillos.region_enabled =true
	_actualizar_ui()

func recibir_danio(danio: int) -> void:
	if inmune:
		return
	vida_actual =max(0, vida_actual - danio)
	_actualizar_ui()
	_animar_danio()
	if vida_actual <=0:
		vida_agotada.emit()

func curar(cantidad: int) -> void:
	vida_actual =min(VIDA_MAX, vida_actual + cantidad)
	_actualizar_ui()
	var tw =create_tween()
	tw.tween_property(ladrillos, "modulate", Color.GREEN, 0.06)
	tw.tween_property(ladrillos, "modulate", Color.WHITE, 0.2)

func _actualizar_ui() -> void:
	label.text =str(vida_actual)
	var porcentaje =float(vida_actual) / float(VIDA_MAX)
	var tex =ladrillos.texture
	if tex ==null:
		return
	var alto_total =tex.get_height()
	var alto_visible =alto_total * porcentaje
	var recorte_top =alto_total - alto_visible
	ladrillos.region_rect =Rect2(0, recorte_top, tex.get_width(), alto_visible)
	var orig_offset =ladrillos.offset
	ladrillos.offset =Vector2(orig_offset.x, -recorte_top / 2.0)

func _animar_danio() -> void:
	var tw =create_tween()
	tw.tween_property(ladrillos, "modulate", Color.RED, 0.06)
	tw.tween_property(ladrillos, "modulate", Color.WHITE, 0.2)
