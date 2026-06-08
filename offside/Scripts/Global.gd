extends Node

enum Escenario {TUTORIAL, CUARTOS, SEMIS, FINAL}

var escenario_actual: Escenario= Escenario.TUTORIAL
var pais_jugador: JugadorData.Pais= JugadorData.Pais.ARGENTINA

var musica_menu: AudioStreamPlayer

func _ready() -> void:
	musica_menu = AudioStreamPlayer.new()
	musica_menu.stream = load("res://Audio/MusicaFondoMenus.mp3")
	musica_menu.volume_db = -12.0
	musica_menu.bus = "Master"
	musica_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(musica_menu)
	musica_menu.finished.connect(_on_musica_menu_terminada)

func _on_musica_menu_terminada() -> void:
	musica_menu.play()

func iniciar_musica_menu() -> void:
	if !musica_menu.playing:
		musica_menu.play()

func parar_musica_menu() -> void:
	musica_menu.stop()
