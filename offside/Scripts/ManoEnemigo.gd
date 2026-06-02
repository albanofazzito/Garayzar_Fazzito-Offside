class_name ManoEnemigo
extends Node2D

var maso: Array= []
var maso_actual: Array =[]
var cartas_en_mano: Array= []
var cartas_max: int =7
@export var pais: JugadorData.Pais= JugadorData.Pais.PORTUGAL
var escenaCarta =preload("res://Escenas/Carta.tscn")
enum Estado {TURNO_JUGADOR, ESPERANDO_BATALLA, BATALLANDO}
var estado= Estado.TURNO_JUGADOR
@export var batalla_manager: BatallaManager
@export var boton_turno: Button
@export var label_estrellas_enemigo: Label
var mano: Mano
var estrellas:int= 1
var estrellas_max: int =1
static var es_turno_jugador: bool =true

var angulo_mano: float =20.0
var espaciado_mano: float= 80.0


func _ready() -> void:
	mano= get_parent().get_node("ManoJugador/Mano") as Mano
	_actualizar_boton()
	_actualizar_label_estrellas()

func iniciar() -> void:
	cargar_maso(pais)
	_robar_iniciales()

func _robar_iniciales() -> void:
	for i in 3:
		_robar_carta()

func cargar_maso(p: JugadorData.Pais) -> void:
	maso.clear()
	_escanear_carpeta("res://Scripts/JugadoresData/", p)
	_escanear_carpeta("res://Scripts/TrucosData/", p)
	maso_actual= maso.duplicate()
	maso_actual.shuffle()

func _escanear_carpeta(ruta: String, p: JugadorData.Pais) -> void:
	var dir =DirAccess.open(ruta)
	if !dir:
		return
	for archivo in dir.get_files():
		if archivo.ends_with(".tres"):
			var datos= load(ruta + archivo)
			if datos.pais== p:
				maso.append(ruta + archivo)
	for subcarpeta in dir.get_directories():
		_escanear_carpeta(ruta + subcarpeta + "/", p)

func _robar_carta() -> void:
	if cartas_en_mano.size() >=cartas_max:
		return
	if maso_actual.is_empty():
		maso_actual =maso.duplicate()
		maso_actual.shuffle()
	var ruta= maso_actual.pop_back()
	var carta =escenaCarta.instantiate() as Carta
	add_child(carta)
	carta.datos= load(ruta)
	carta.en_mano =true
	carta.scale= Vector2(0.45, 0.45)
	carta.rotation= deg_to_rad(180)
	carta.get_node("Base").visible= false
	carta.get_node("BaseTruco").visible =false
	carta.get_node("BaseAtras").visible= true
	carta.frente_visible =false
	cartas_en_mano.append(carta)
	_ordenar_mano()

func _ordenar_mano() -> void:
	var count= cartas_en_mano.size()
	for i in count:
		var carta =cartas_en_mano[i]
		var offset= (i - (count - 1) / 2.0)
		var pos =Vector2(offset * espaciado_mano, 0)
		pos.y += abs(offset) *10.0
		var rot= deg_to_rad(offset * angulo_mano / max(count, 1)) + deg_to_rad(180)
		carta.position =pos
		carta.rotation= rot

func jugar_turno() -> void:
	for slot in get_tree().get_nodes_in_group("slots_enemigo"):
		if slot.carta_actual== null:
			var coloco= await _intentar_colocar(slot)
			if coloco:
				await get_tree().create_timer(0.4).timeout

func _intentar_colocar(slot: Slot) -> bool:
	for i in cartas_en_mano.size():
		var carta= cartas_en_mano[i]
		var datos =carta.datos
		if datos is JugadorData and _puede_ir(datos, slot) and datos.estrellas<= estrellas:
			cartas_en_mano.remove_at(i)
			carta.en_mano =false
			carta.z_index= -1
			carta.scale =Vector2(0.6, 0.6)
			carta.rotation= 0.0
			carta.get_node("Base").visible= !carta.datos is TrucoData
			carta.get_node("BaseTruco").visible =carta.datos is TrucoData
			carta.get_node("BaseAtras").visible= false
			carta.frente_visible =true
			var destino= to_local(slot.get_global_rect().get_center())
			carta.posicion_original =destino
			carta.rotacion_original= 0.0
			carta.animar(destino, 0.0)
			slot.carta_actual= carta
			estrellas -=datos.estrellas
			_actualizar_label_estrellas()
			_ordenar_mano()
			return true
	return false

func _puede_ir(datos: JugadorData, slot: Slot) -> bool:
	if datos.posicion ==JugadorData.Posicion.TODO:
		return true
	if datos.efecto_tipo== JugadorData.EfectoJugador.MULTIPOSICION:
		return true
	match slot.columna:
		0:
			return datos.posicion== JugadorData.Posicion.DELANTERO
		1:
			return datos.posicion ==JugadorData.Posicion.MEDIOCAMPISTA or datos.posicion== JugadorData.Posicion.DELANTERO
		2:
			return datos.posicion ==JugadorData.Posicion.MEDIOCAMPISTA
		3:
			return datos.posicion== JugadorData.Posicion.DEFENSOR
		4:
			return datos.posicion ==JugadorData.Posicion.ARQUERO or datos.posicion== JugadorData.Posicion.DEFENSOR
	return false

func sumar_estrella() -> void:
	estrellas_max +=1
	estrellas= estrellas_max
	_actualizar_label_estrellas()

func _on_pasar_turno_pressed() -> void:
	if estado!= Estado.TURNO_JUGADOR:
		return
	_animar_boton()
	estado= Estado.ESPERANDO_BATALLA
	es_turno_jugador =false
	_actualizar_boton()
	boton_turno.disabled =true
	await jugar_turno()
	await get_tree().create_timer(0.5).timeout
	estado =Estado.BATALLANDO
	_actualizar_boton()
	batalla_manager.iniciar_batalla()


func _on_batalla_manager_batalla_terminada() -> void:
	estado= Estado.TURNO_JUGADOR
	es_turno_jugador =true
	_actualizar_boton()
	boton_turno.disabled= false
	mano.sumar_estrella()
	sumar_estrella()
	if mano.cartas.size() <mano.cartas_max:
		mano.agregar()
	_robar_carta()

func _actualizar_boton() -> void:
	if !boton_turno:
		return
	match estado:
		Estado.TURNO_JUGADOR:
			boton_turno.text= "▶ Mi turno"
			boton_turno.modulate =Color(0.2, 0.8, 0.2)
		Estado.ESPERANDO_BATALLA:
			boton_turno.text ="⏳ Rival"
			boton_turno.modulate= Color(1.0, 0.6, 0.0)
		Estado.BATALLANDO:
			boton_turno.text= "⚔ Batalla!"
			boton_turno.modulate =Color(1.0, 0.2, 0.2)

func _animar_boton() -> void:
	if !boton_turno:
		return
	var tw= create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(boton_turno, "scale", Vector2(1.2, 1.2), 0.1)
	tw.tween_property(boton_turno, "scale", Vector2(1.0, 1.0), 0.15)

func _actualizar_label_estrellas() -> void:
	if !label_estrellas_enemigo:
		return
	label_estrellas_enemigo.text =str(estrellas) + "/" + str(estrellas_max)
