extends Node2D

@onready var pantalla_fin =$PantallaFin
@onready var mensaje =$PantallaFin/Mensaje
@onready var tutorial =$Tutorial
@onready var mano_enemigo =$ManoEnemigo

func _ready() -> void:
	var escenario= Global.escenario_actual
	match escenario:
		Global.Escenario.TUTORIAL:
			mano_enemigo.pais= JugadorData.Pais.BRASIL
			var mano = $ManoJugador/Mano as Mano
			mano.en_tutorial = true
			tutorial.iniciar(mano)
			tutorial.tutorial_finalizado.connect(_on_tutorial_fin)
		Global.Escenario.CUARTOS:
			mano_enemigo.pais= JugadorData.Pais.BRASIL
			tutorial.queue_free()
		Global.Escenario.SEMIS:
			mano_enemigo.pais= JugadorData.Pais.FRANCIA
			tutorial.queue_free()
		Global.Escenario.FINAL:
			mano_enemigo.pais= JugadorData.Pais.PORTUGAL
			tutorial.queue_free()
	mano_enemigo.iniciar()

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
	var escenario= Global.escenario_actual
	match escenario:
		Global.Escenario.TUTORIAL:
			get_tree().change_scene_to_file("res://Escenas/Cuartos.tscn")
		Global.Escenario.CUARTOS:
			get_tree().change_scene_to_file("res://Escenas/Semis.tscn")
		Global.Escenario.SEMIS:
			get_tree().change_scene_to_file("res://Escenas/Final.tscn")
		Global.Escenario.FINAL:
			get_tree().change_scene_to_file("res://Escenas/Campeon.tscn")

func _on_boton_derrota_pressed() -> void:
	get_tree().paused =false
	get_tree().change_scene_to_file("res://Escenas/Menu.tscn")
