extends Control

const Menu = "res://Escenas/Menu.tscn"

var _fondos= {
	JugadorData.Pais.ARGENTINA: "res://Sprites/Fases/CampeonArgentina.jpg",
}

func _ready() -> void:
	var pais= Global.pais_jugador
	if pais in _fondos:
		$TextureRect.texture= load(_fondos[pais])

func _on_button_pressed() -> void:
	Transicion.cambiar_escena(Menu)
