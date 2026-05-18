extends Node2D

var cartas : Array = []
var cartas_max: int = 7
var maso: Array = []
var maso_actual: Array = []

func _ready():
	var dir = DirAccess.open("res://Scripts/JugadoresData/")
	for archivo in dir.get_files():
		if archivo.ends_with(".tres"):
			maso.append(archivo.replace(".tres", ""))
	maso_actual = maso.duplicate()
	maso_actual.shuffle()

@export var angulo: float = 30.0
@export var spaciado: float = 120.0

var escenaCarta= load("res://Escenas/Carta.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and cartas.size()<cartas_max:
		if event.keycode == KEY_SPACE and event.pressed:
			agregar()

func cargar_jugador(nombre) -> JugadorData:
	return load("res://Scripts/JugadoresData/" + nombre + ".tres")

func robar_carta() -> String:
	if maso_actual.is_empty():
		maso_actual = maso.duplicate()
		maso_actual.shuffle()
	return maso_actual.pop_back()

func agregar() -> void:
	var nombre = robar_carta()
	var datos = cargar_jugador(nombre)
	var carti = escenaCarta.instantiate() as Carta
	add_child(carti)
	if datos:
		carti.datos = datos
	cartas.append(carti)
	orden()

func sacar(escenaCarta) -> void:
	cartas.erase(escenaCarta)
	escenaCarta.queue_free()
	orden()        

func orden() -> void:
	var count = cartas.size()
	for i in count:
		var Carta = cartas[i]
		var offset = (i - (count - 1) / 2.0)
		var r= 0
		Carta.position.x= offset * spaciado
