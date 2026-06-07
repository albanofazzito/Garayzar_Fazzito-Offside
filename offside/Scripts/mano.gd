class_name Mano
extends Node2D

var cartas : Array = []
var cartas_max: int = 7
var maso: Array = []
var maso_actual: Array = []
@export var angulo: float= 30.0
@export var spaciado: float= 120.0
var mano_levantada: bool = false
var estaba_en_zona: bool = false
var estrellas : int= 1
var estrellas_max : int= 1
@onready var label_estrellas : Label= $LabelEstrellas

var paisActual= JugadorData.Pais.ARGENTINA
var escenaCarta= load("res://Escenas/Carta.tscn")
var efecto_manager: EfectoManager
var en_tutorial: bool = false
var sfx_woosh1: AudioStreamPlayer
var sfx_woosh2: AudioStreamPlayer
var _banderas: Dictionary= {
	JugadorData.Pais.ARGENTINA: preload("res://Sprites/Paises/Argentina/Bandera/banderaArgentina.png"),
	JugadorData.Pais.BRASIL: preload("res://Sprites/Paises/Brasil/Bandera/banderaBrasil.png"),
	JugadorData.Pais.FRANCIA: preload("res://Sprites/Paises/Francia/Bandera/banderaFrancia.png"),
	JugadorData.Pais.PORTUGAL: preload("res://Sprites/Paises/Portugal/Bandera/banderaPortugal.png"),
}
func _ready() -> void:
	add_to_group("mano_jugador")
	efecto_manager =EfectoManager.new()
	add_child(efecto_manager)
	sfx_woosh1 =AudioStreamPlayer.new()
	sfx_woosh1.stream= load("res://Audio/woosh1.mp3")
	sfx_woosh1.volume_db= -10.0
	add_child(sfx_woosh1)
	sfx_woosh2 =AudioStreamPlayer.new()
	sfx_woosh2.stream= load("res://Audio/woosh2.wav")
	sfx_woosh2.volume_db= -10.0
	add_child(sfx_woosh2)
	paisActual =Global.pais_jugador
	cargar_maso(paisActual)
	_actualizar_label()
	_robar_iniciales()
	


func _robar_iniciales() -> void:
	for i in 3:
		agregar()
		await get_tree().create_timer(0.6).timeout

func cargar_maso(pais: JugadorData.Pais) -> void:
	maso.clear()
	_escanear_carpeta("res://Scripts/JugadoresData/", pais)
	_escanear_carpeta("res://Scripts/TrucosData/", pais)
	maso_actual = maso.duplicate()
	maso_actual.shuffle()

func _escanear_carpeta(ruta: String, pais: JugadorData.Pais) -> void:
	var dir =DirAccess.open(ruta)
	if !dir:
		return
	for archivo in dir.get_files():
		if archivo.ends_with(".tres"):
			var carta= load(ruta + archivo)
			if carta.pais ==pais or (carta is TrucoData and carta.es_universal):
				maso.append(ruta + archivo)
	for subcarpeta in dir.get_directories():
		_escanear_carpeta(ruta + subcarpeta + "/", pais)



func cargar_jugador(ruta: String) -> Resource:
	return load(ruta) 

func robar_carta() -> String:
	if maso_actual.is_empty():
		maso_actual= maso.duplicate()
		maso_actual.shuffle()
	return maso_actual.pop_back()

func agregar() -> void:
	var nombre= robar_carta()
	var datos= cargar_jugador(nombre)
	var carti= escenaCarta.instantiate() as Carta
	add_child(carti)
	if datos:
		carti.datos= datos.duplicate()
		if carti.datos is TrucoData and carti.datos.es_universal and carti.datos.bandera== null:
			carti.datos.bandera= _banderas.get(paisActual)
			carti.actualizar_carta()
		carti.get_node("Base/RecipienteEstrellas/Coste").text =str(datos.estrellas)
	cartas.append(carti)
	orden()
	_animar_entrada(carti)
	sfx_woosh1.play()

func _animar_entrada(carti: Carta) -> void:
	var viewport_size =get_viewport().get_visible_rect().size
	var centro_pantalla =to_local(Vector2(viewport_size.x / 2.0, viewport_size.y / 2.0 + 80.0))
	var pos_destino =Vector2(carti.posicion_original.x, carti.posicion_original.y + Carta.y_oculto)
	var pivot_local =Vector2(0, -176.0)
	
	carti.position =centro_pantalla
	carti.scale =Vector2(0.0, 0.0)
	carti.rotation =0.0
	carti.modulate.a =0.0
	carti.z_index =10
	
	var tw =carti.create_tween()
	tw.tween_property(carti, "scale", Vector2(0.72, 0.72), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(carti, "modulate:a", 1.0, 0.15)
	tw.parallel().tween_method(func(angulo: float):
		carti.rotation =angulo
		var offset =pivot_local * carti.scale.x
		carti.position =centro_pantalla + offset - offset.rotated(angulo)
	, 0.0, deg_to_rad(720.0), 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tw.tween_property(carti, "scale", Vector2(0.66, 0.66), 0.12).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tw.tween_property(carti, "scale", Vector2(0.7, 0.7), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_interval(0.4)
	
	tw.tween_property(carti, "rotation", 0.0, 0.0)
	tw.tween_callback(func(): carti.position =centro_pantalla)
	tw.tween_property(carti, "position", pos_destino, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tw.parallel().tween_property(carti, "scale", Vector2(0.6, 0.6), 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(carti, "rotation", carti.rotacion_original, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(carti, "z_index", 0, 0.0)

func sacar(escenaCarta) -> void:
	cartas.erase(escenaCarta)
	escenaCarta.queue_free()
	orden()        

func orden() -> void:
	var count = cartas.size()
	for i in count:
		var carta = cartas[i]
		var offset = (i - (count - 1) / 2.0)
		var pos = Vector2(offset * spaciado, 0)
		pos.y += abs(offset) * 20.0
		var rot = deg_to_rad(offset * angulo / max(count, 1))
		carta.orden_externo(pos, rot)

func _process(delta: float) -> void:
	var altura =get_viewport().get_visible_rect().size.y
	var mouse_y =get_viewport().get_mouse_position().y
	const OCULTO =280.0
	const ZONA =0.28
	var y_inicio =altura * (1.0 - ZONA)
	var en_zona =mouse_y >= y_inicio

	if en_zona and !estaba_en_zona:
		mano_levantada =!mano_levantada
	estaba_en_zona =en_zona

	var y_target: float
	if Carta.carta_siendo_arrastrada !=null:
		y_target =OCULTO 
	else:
		y_target =0.0 if mano_levantada else OCULTO

	var nuevo =lerp(Carta.y_oculto, y_target, delta * 12.0)
	if abs(nuevo - Carta.y_oculto) > 0.1:
		Carta.y_oculto =nuevo
		orden()

func sumar_estrella() -> void:
	estrellas_max +=1
	estrellas =estrellas_max
	_actualizar_label()

func gastar_estrellas(costo : int) -> void:
	estrellas =max(0, estrellas - costo)
	_actualizar_label()

func jugar_truco(carta: Carta, columna: int) -> void:
	gastar_estrellas(carta.datos.estrellas)
	efecto_manager.ejecutar(carta.datos as TrucoData, self, columna)
	cartas.erase(carta)
	var tw =carta.create_tween()
	tw.tween_property(carta, "scale", Vector2(1.3, 1.3), 0.08)
	tw.tween_property(carta, "modulate:a", 0.0, 0.2)
	await tw.finished
	carta.queue_free()
	orden()

func _actualizar_label() -> void:
	label_estrellas.text =str(estrellas) + "/" +str(estrellas_max)
