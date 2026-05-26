extends Node2D

var cartas : Array = []
var cartas_max: int = 7
var maso: Array = []
var maso_actual: Array = []
@export var angulo: float= 30.0
@export var spaciado: float= 120.0
var mano_levantada: bool = false
var estaba_en_zona: bool = false

var paisActual= JugadorData.Pais.ARGENTINA
var escenaCarta= load("res://Escenas/Carta.tscn")
func _ready() -> void:
	cargar_maso(paisActual)


func cargar_maso(pais: JugadorData.Pais) -> void:
	maso.clear()
	var carpetas = ["res://Scripts/JugadoresData/", "res://Scripts/TrucosData/"]
	for carpeta in carpetas:
		var dir = DirAccess.open(carpeta)
		if dir:
			for archivo in dir.get_files():
				if archivo.ends_with(".tres"):
					var carta = load(carpeta + archivo)
					if carta.pais == pais:
						maso.append(carpeta + archivo)
	maso_actual = maso.duplicate()
	maso_actual.shuffle()



func _input(event: InputEvent) -> void:
	if event is InputEventKey and cartas.size()<cartas_max:
		if event.keycode == KEY_SPACE and event.pressed:
			agregar()

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
		carti.datos= datos
	cartas.append(carti)
	orden()

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
