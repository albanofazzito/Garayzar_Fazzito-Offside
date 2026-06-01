extends Node2D

@onready var pantalla_fin =$PantallaFin
@onready var mensaje =$PantallaFin/Mensaje
@onready var tutorial =$Tutorial

var tutorial_visto: bool = false

func _ready() -> void:
	if !tutorial_visto:
		var mano = $ManoJugador/Mano as Mano
		mano.en_tutorial = true
		tutorial.iniciar(mano)
		tutorial.tutorial_finalizado.connect(_on_tutorial_fin)
		tutorial_visto = true

func _on_tutorial_fin() -> void:
	var mano = $ManoJugador/Mano as Mano
	mano.en_tutorial = false

func _on_derrota() -> void:
	mensaje.text ="DERROTA"
	mensaje.modulate =Color(1.0, 0.3, 0.3)
	_mostrar_pantalla()

func _on_victoria() -> void:
	mensaje.text ="VICTORIA"
	mensaje.modulate= Color(0.3, 1.0, 0.4)
	_mostrar_pantalla()

func _mostrar_pantalla() -> void:
	if mensaje.text== "DERROTA":
		$PantallaDerrota.visible =true
	else:
		$PantallaFin.visible=true
	get_tree().paused =true

func _on_boton_menu_pressed() -> void:
	get_tree().paused =false
	get_tree().change_scene_to_file("res://Escenas/Menu.tscn")
