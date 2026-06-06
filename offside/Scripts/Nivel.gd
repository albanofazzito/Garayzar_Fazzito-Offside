extends Node2D

@onready var pantalla_fin =$PantallaFin
@onready var mensaje =$PantallaFin/Mensaje
@onready var tutorial =$Tutorial
@onready var mano_enemigo =$ManoEnemigo
var musica_fondo: AudioStreamPlayer

func _ready() -> void:
	musica_fondo =AudioStreamPlayer.new()
	var escenario= Global.escenario_actual
	match escenario:
		Global.Escenario.TUTORIAL, Global.Escenario.CUARTOS:
			musica_fondo.stream= load("res://Audio/MusicaFondoCuartos.mp3")
		Global.Escenario.SEMIS:
			musica_fondo.stream= load("res://Audio/MusicaFondoSemis.mp3")
		Global.Escenario.FINAL:
			musica_fondo.stream= load("res://Audio/musicaFondo.mp3")
	musica_fondo.volume_db= -14.0
	musica_fondo.bus ="Master"
	add_child(musica_fondo)
	musica_fondo.finished.connect(_on_musica_terminada)
	musica_fondo.play()

	var pj= Global.pais_jugador
	match escenario:
		Global.Escenario.TUTORIAL:
			var enemigo_base= JugadorData.Pais.BRASIL
			mano_enemigo.pais= enemigo_base if pj != enemigo_base else JugadorData.Pais.ARGENTINA
			var mano_j = $ManoJugador/Mano as Mano
			mano_j.en_tutorial = true
			tutorial.iniciar(mano_j)
			tutorial.tutorial_finalizado.connect(_on_tutorial_fin)
		Global.Escenario.CUARTOS:
			var enemigo_base= JugadorData.Pais.BRASIL
			mano_enemigo.pais= enemigo_base if pj != enemigo_base else JugadorData.Pais.ARGENTINA
			tutorial.queue_free()
		Global.Escenario.SEMIS:
			var enemigo_base= JugadorData.Pais.FRANCIA
			mano_enemigo.pais= enemigo_base if pj != enemigo_base else JugadorData.Pais.ARGENTINA
			tutorial.queue_free()
		Global.Escenario.FINAL:
			var enemigo_base= JugadorData.Pais.PORTUGAL
			mano_enemigo.pais= enemigo_base if pj != enemigo_base else JugadorData.Pais.ARGENTINA
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

func _on_musica_terminada() -> void:
	musica_fondo.play()
