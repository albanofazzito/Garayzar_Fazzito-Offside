extends Control

const SiguienteNivel = "res://Escenas/Nivel.tscn"
const Menu = "res://Escenas/Menu.tscn"

var _fondos= {
	JugadorData.Pais.ARGENTINA: "res://Sprites/Fases/SemisArgentina.jpg",
	JugadorData.Pais.BRASIL: "res://Sprites/Fases/Semis_Brasil.jpg",
	JugadorData.Pais.FRANCIA: "res://Sprites/Fases/SemisArgentina.jpg",
	JugadorData.Pais.PORTUGAL: "res://Sprites/Fases/Semis_Portugal.jpg",
}

func _ready() -> void:
	get_tree().paused = false
	ManoEnemigo.es_turno_jugador = true
	Carta.carta_siendo_arrastrada = null
	Carta.y_oculto = 280.0
	$TextureRect.mouse_filter= Control.MOUSE_FILTER_IGNORE
	var pais= Global.pais_jugador
	if pais in _fondos:
		$TextureRect.texture= load(_fondos[pais])

func _on_button_pressed() -> void:
	Transicion.cambiar_escena(Menu)


func _on_button_2_pressed() -> void:
	Global.escenario_actual= Global.Escenario.SEMIS
	Transicion.cambiar_escena(SiguienteNivel)
