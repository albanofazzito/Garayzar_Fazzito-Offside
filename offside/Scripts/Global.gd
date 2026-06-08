extends Node

enum Escenario {TUTORIAL, CUARTOS, SEMIS, FINAL}

var escenario_actual: Escenario= Escenario.TUTORIAL
var pais_jugador: JugadorData.Pais= JugadorData.Pais.ARGENTINA

var musica_menu: AudioStreamPlayer
var sfx_boton: AudioStreamPlayer

func _ready() -> void:
	musica_menu = AudioStreamPlayer.new()
	musica_menu.stream = load("res://Audio/MusicaFondoMenus.mp3")
	musica_menu.volume_db = -12.0
	musica_menu.bus = "Master"
	musica_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(musica_menu)
	musica_menu.finished.connect(_on_musica_menu_terminada)
	sfx_boton = AudioStreamPlayer.new()
	sfx_boton.stream = load("res://Audio/seleccionar.mp3")
	sfx_boton.volume_db = -5.0
	sfx_boton.bus = "Master"
	sfx_boton.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(sfx_boton)

func _on_musica_menu_terminada() -> void:
	musica_menu.play()

func iniciar_musica_menu() -> void:
	if !musica_menu.playing:
		musica_menu.play()

func parar_musica_menu() -> void:
	musica_menu.stop()

func play_sfx_boton() -> void:
	sfx_boton.play()
