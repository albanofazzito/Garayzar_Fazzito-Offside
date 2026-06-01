class_name ManoEnemigo
extends Node2D

var maso: Array= []
var maso_actual: Array = []
@export var pais: JugadorData.Pais =JugadorData.Pais.PORTUGAL
var escenaCarta= preload("res://Escenas/Carta.tscn")
enum Estado {TURNO_JUGADOR, ESPERANDO_BATALLA, BATALLANDO}
var estado =Estado.TURNO_JUGADOR
@export var batalla_manager: BatallaManager
@export var boton_turno: Button
@export var label_estrellas_enemigo: Label
var mano: Mano
var estrellas:int = 1
var estrellas_max: int = 1 
static var es_turno_jugador: bool= true


func _ready() -> void:
	mano =get_parent().get_node("ManoJugador/Mano") as Mano
	cargar_maso(pais)
	_actualizar_boton()
	_actualizar_label_estrellas()

func cargar_maso(p: JugadorData.Pais) -> void:
	maso.clear()
	var carpetas= ["res://Scripts/JugadoresData/", "res://Scripts/TrucosData/"]
	for carpeta in carpetas:
		var dir =DirAccess.open(carpeta)
		if dir:
			for archivo in dir.get_files():
				if archivo.ends_with(".tres"):
					var datos= load(carpeta + archivo)
					if datos.pais ==p:
						maso.append(carpeta + archivo)
	maso_actual =maso.duplicate()
	maso_actual.shuffle()

func jugar_turno() -> void:
	for slot in get_tree().get_nodes_in_group("slots_enemigo"):
		if slot.carta_actual ==null:
			var coloco =await _intentar_colocar(slot)
			if coloco:
				await get_tree().create_timer(0.4).timeout

func _intentar_colocar(slot: Slot) -> bool:
	for i in maso_actual.size():
		var datos =load(maso_actual[i])
		if datos is JugadorData and datos.posicion ==slot.tipo and datos.estrellas <=estrellas:
			var carta= escenaCarta.instantiate() as Carta
			add_child(carta)
			carta.datos =datos
			carta.en_mano= false
			carta.z_index =-1
			var destino = to_local(slot.get_global_rect().get_center())
			carta.position =Vector2(destino.x, -200)
			carta.posicion_original= destino
			carta.rotacion_original =0.0
			carta.animar(destino, 0.0)
			slot.carta_actual =carta
			maso_actual.remove_at(i)
			estrellas -=datos.estrellas
			_actualizar_label_estrellas()
			return true
	return false

func sumar_estrella() -> void:  
	estrellas_max +=1
	estrellas =estrellas_max
	_actualizar_label_estrellas()
	
func _on_pasar_turno_pressed() -> void:
	if estado !=Estado.TURNO_JUGADOR:
		return
	_animar_boton()
	estado =Estado.ESPERANDO_BATALLA
	es_turno_jugador =false
	_actualizar_boton()
	boton_turno.disabled= true
	await jugar_turno()
	await get_tree().create_timer(0.5).timeout
	estado =Estado.BATALLANDO
	_actualizar_boton()
	batalla_manager.iniciar_batalla()


func _on_batalla_manager_batalla_terminada() -> void:
	estado =Estado.TURNO_JUGADOR
	es_turno_jugador =true
	_actualizar_boton()
	boton_turno.disabled =false
	mano.sumar_estrella()
	sumar_estrella()
	if mano.cartas.size() <mano.cartas_max:
		mano.agregar()

func _actualizar_boton() -> void:
	if !boton_turno:
		return
	match estado:
		Estado.TURNO_JUGADOR:
			boton_turno.text ="▶ Mi turno"
			boton_turno.modulate= Color(0.2, 0.8, 0.2)
		Estado.ESPERANDO_BATALLA:
			boton_turno.text= "⏳ Rival"
			boton_turno.modulate =Color(1.0, 0.6, 0.0)
		Estado.BATALLANDO:
			boton_turno.text ="⚔ Batalla!"
			boton_turno.modulate= Color(1.0, 0.2, 0.2)

func _animar_boton() -> void:
	if !boton_turno:
		return
	var tw =create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(boton_turno, "scale", Vector2(1.2, 1.2), 0.1)
	tw.tween_property(boton_turno, "scale", Vector2(1.0, 1.0), 0.15)

func _actualizar_label_estrellas() -> void:
	if !label_estrellas_enemigo:
		return
	label_estrellas_enemigo.text= str(estrellas) + "/" +str(estrellas_max)
