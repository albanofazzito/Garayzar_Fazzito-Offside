extends Node2D

@onready var pantalla_fin =$PantallaFin
@onready var mensaje =$PantallaFin/Mensaje
@onready var tutorial =$Tutorial
@onready var mano_enemigo =$ManoEnemigo
var musica_fondo: AudioStreamPlayer

var _pantallas_derrota= {
	JugadorData.Pais.ARGENTINA: "res://Sprites/Fases/PantallaDerrotaArgentina.jpg",
	JugadorData.Pais.BRASIL: "res://Sprites/Fases/PantallaDerrotaBrasil.png",
	JugadorData.Pais.FRANCIA: "res://Sprites/Fases/PantallaDerrotaFancia.png",
	JugadorData.Pais.PORTUGAL: "res://Sprites/Fases/PantallaDerrotaPortugal.png",
}

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
	musica_fondo.process_mode= Node.PROCESS_MODE_ALWAYS
	add_child(musica_fondo)
	musica_fondo.finished.connect(_on_musica_terminada)
	musica_fondo.play()

	var pj= Global.pais_jugador
	var enemigo= _elegir_enemigo(pj, escenario)
	match escenario:
		Global.Escenario.TUTORIAL:
			mano_enemigo.pais= enemigo
			var mano_j = $ManoJugador/Mano as Mano
			mano_j.en_tutorial = true
			tutorial.iniciar(mano_j)
			tutorial.tutorial_finalizado.connect(_on_tutorial_fin)
		Global.Escenario.CUARTOS:
			mano_enemigo.pais= enemigo
			tutorial.queue_free()
		Global.Escenario.SEMIS:
			mano_enemigo.pais= enemigo
			tutorial.queue_free()
		Global.Escenario.FINAL:
			mano_enemigo.pais= enemigo
			tutorial.queue_free()
	mano_enemigo.iniciar()

func _on_tutorial_fin() -> void:
	var mano = $ManoJugador/Mano as Mano
	mano.en_tutorial = false

func _on_derrota() -> void:
	mensaje.text ="DERROTA"
	mensaje.modulate =Color(1.0, 0.3, 0.3)
	var pj= Global.pais_jugador
	if pj in _pantallas_derrota:
		$PantallaDerrota/Fondo.texture= load(_pantallas_derrota[pj])
	_mostrar_pantalla()

func _on_victoria() -> void:
	mensaje.text ="VICTORIA"
	mensaje.modulate= Color(0.3, 1.0, 0.4)
	_mostrar_pantalla()

func _mostrar_pantalla() -> void:
	if mensaje.text== "DERROTA":
		$PantallaDerrota.visible =true
		$PantallaDerrota/Fondo.modulate.a = 0.0
		$PantallaDerrota/BotonReintentar.modulate.a = 0.0
		$PantallaDerrota/BotonMenuDerrota.modulate.a = 0.0
		var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property($PantallaDerrota/Fondo, "modulate:a", 1.0, 0.8).set_trans(Tween.TRANS_SINE)
		tw.tween_property($PantallaDerrota/BotonReintentar, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
		tw.parallel().tween_property($PantallaDerrota/BotonMenuDerrota, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
	else:
		$PantallaFin.visible=true
		$PantallaFin/BotonMenu.text= "Siguiente"
	get_tree().paused =true

func _on_boton_reintentar_pressed() -> void:
	var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property($PantallaDerrota/BotonReintentar, "modulate:a", 0.0, 0.2)
	tw.parallel().tween_property($PantallaDerrota/BotonMenuDerrota, "modulate:a", 0.0, 0.2)
	tw.tween_property($PantallaDerrota/Fondo, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE)
	tw.finished.connect(func():
		get_tree().paused =false
		Transicion.cambiar_escena("res://Escenas/Nivel.tscn")
	)

func _on_boton_derrota_pressed() -> void:
	var tw = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property($PantallaDerrota/BotonReintentar, "modulate:a", 0.0, 0.2)
	tw.parallel().tween_property($PantallaDerrota/BotonMenuDerrota, "modulate:a", 0.0, 0.2)
	tw.tween_property($PantallaDerrota/Fondo, "modulate:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE)
	tw.finished.connect(func():
		get_tree().paused =false
		Transicion.cambiar_escena("res://Escenas/Menu.tscn")
	)

func _on_boton_menu_pressed() -> void:
	get_tree().paused =false
	var escenario= Global.escenario_actual
	match escenario:
		Global.Escenario.TUTORIAL:
			Transicion.cambiar_escena("res://Escenas/Cuartos.tscn")
		Global.Escenario.CUARTOS:
			Transicion.cambiar_escena("res://Escenas/Semis.tscn")
		Global.Escenario.SEMIS:
			Transicion.cambiar_escena("res://Escenas/Final.tscn")
		Global.Escenario.FINAL:
			Transicion.cambiar_escena("res://Escenas/Campeon.tscn")

func _on_musica_terminada() -> void:
	musica_fondo.play()

func _elegir_enemigo(pj: JugadorData.Pais, escenario: Global.Escenario) -> JugadorData.Pais:
	var rivales= {
		JugadorData.Pais.ARGENTINA: [JugadorData.Pais.BRASIL, JugadorData.Pais.BRASIL, JugadorData.Pais.FRANCIA, JugadorData.Pais.PORTUGAL],
		JugadorData.Pais.BRASIL: [JugadorData.Pais.ARGENTINA, JugadorData.Pais.ARGENTINA, JugadorData.Pais.FRANCIA, JugadorData.Pais.PORTUGAL],
		JugadorData.Pais.FRANCIA: [JugadorData.Pais.BRASIL, JugadorData.Pais.BRASIL, JugadorData.Pais.PORTUGAL, JugadorData.Pais.ARGENTINA],
		JugadorData.Pais.PORTUGAL: [JugadorData.Pais.BRASIL, JugadorData.Pais.BRASIL, JugadorData.Pais.FRANCIA, JugadorData.Pais.ARGENTINA],
	}
	var indice= escenario as int
	if pj in rivales:
		return rivales[pj][indice]
	return JugadorData.Pais.ARGENTINA
