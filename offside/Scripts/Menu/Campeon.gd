extends Control

const Menu = "res://Escenas/Menu.tscn"

var _fondos= {
	JugadorData.Pais.ARGENTINA: "res://Sprites/Fases/CampeonArgentina.jpg",
	JugadorData.Pais.BRASIL: "res://Sprites/Fases/CampeonArgentina.jpg",
	JugadorData.Pais.FRANCIA: "res://Sprites/Fases/CampeonArgentina.jpg",
	JugadorData.Pais.PORTUGAL: "res://Sprites/Fases/CampeonArgentina.jpg",
}

func _ready() -> void:
	get_tree().paused = false
	Global.iniciar_musica_menu()
	$TextureRect.mouse_filter= Control.MOUSE_FILTER_IGNORE
	var pais= Global.pais_jugador
	if pais in _fondos:
		$TextureRect.texture= load(_fondos[pais])

func _on_button_pressed() -> void:
	Global.play_sfx_boton()
	Transicion.cambiar_escena(Menu)
