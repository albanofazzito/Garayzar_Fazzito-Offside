class_name ManoEnemigo
extends Node2D

var maso: Array= []
var maso_actual: Array = []
@export var pais: JugadorData.Pais =JugadorData.Pais.BRASIL
var escenaCarta= preload("res://Escenas/Carta.tscn")

func _ready() -> void:
	cargar_maso(pais)

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
			_intentar_colocar(slot)

func _intentar_colocar(slot: Slot) -> void:
	for i in maso_actual.size():
		var datos =load(maso_actual[i])
		if datos is JugadorData and datos.posicion ==slot.tipo:
			var carta= escenaCarta.instantiate() as Carta
			add_child(carta)
			carta.datos =datos
			carta.en_mano= false
			carta.z_index =-1
			var destino= to_local(slot.get_global_rect().get_center())
			carta.position =Vector2(destino.x, -200)
			carta.posicion_original= destino
			carta.rotacion_original =0.0
			carta.animar(destino, 0.0)
			slot.carta_actual =carta
			maso_actual.remove_at(i)
			return


func _on_pasar_turno_pressed() -> void:
	jugar_turno()
