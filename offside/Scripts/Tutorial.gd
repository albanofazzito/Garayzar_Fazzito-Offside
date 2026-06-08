extends CanvasLayer

signal tutorial_finalizado

enum Paso{
	BIENVENIDA,
	VER_MANO,
	VOLTEAR_CARTA,
	VER_STATS,
	COLOCAR_CARTA,
	ESTRELLAS,
	PASAR_TURNO,
	BATALLA,
	FIN
}

var paso_actual: int= Paso.BIENVENIDA
var activo: bool= false
var esperando_accion: bool =false
var mano_ref: Mano
var cartas_al_inicio: int= 0

@onready var fondo: ColorRect =$Fondo
@onready var recuadro: Panel= $Recuadro
@onready var texto: Label =$Texto
@onready var indicador: Label= $Indicador
@onready var flecha: Label =$Flecha

var textos_pasos= {
	0: "¡Bienvenido a OFFSIDE!\nAprendé a jugar paso a paso.\n\n(Click para continuar)",
	1: "TU MANO\nMové el mouse hacia abajo\npara ver tus cartas.",
	2: "VOLTEAR CARTA\nHacé click derecho en una carta\npara ver su reverso.",
	3: "STATS\nCada carta tiene ATAQUE, VIDA\ny VELOCIDAD.\nLa más rápida golpea primero.\n\n(Click para continuar)",
	4: "COLOCAR CARTA\nArrastrá una carta al campo.\nCada una va en su posición.",
	5: "ESTRELLAS\nJugar cartas gasta estrellas.\nCada turno ganás una más.\n\n(Click para continuar)",
	6: "PASAR TURNO\nPresioná el botón para terminar\ntu turno. El rival jugará después.",
	7: "BATALLA\nLas cartas pelean por columna.\nSin rival enfrente, atacan el arco.\n\n(Click para continuar)",
	8: "¡LISTO!\nAlgunas cartas tienen efectos:\nMultiposición, Buff, Esquivar, Rage.\nLos Trucos son de efecto inmediato.\n\n¡Buena suerte! (Click)",
}

var rects_pasos= {
	0: Rect2(376, 224, 400, 150),
	1: Rect2(225, 555, 700, 85),
	2: Rect2(225, 555, 700, 85),
	3: Rect2(225, 555, 700, 85),
	4: Rect2(175, 475, 780, 50),
	5: Rect2(1055, 48, 85, 110),
	6: Rect2(1030, 325, 115, 70),
	7: Rect2(175, 225, 780, 295),
	8: Rect2(351, 199, 450, 220),
}

var textos_pos= {
	0: Vector2(376, 240),
	1: Vector2(370, 380),
	2: Vector2(370, 100),
	3: Vector2(370, 100),
	4: Vector2(310, 300),
	5: Vector2(700, 55),
	6: Vector2(650, 300),
	7: Vector2(376, 50),
	8: Vector2(380, 220),
}

func _ready() -> void:
	visible= false
	process_mode =Node.PROCESS_MODE_ALWAYS

func iniciar(mano: Mano) -> void:
	mano_ref= mano
	activo =true
	visible= true
	paso_actual= Paso.BIENVENIDA
	cartas_al_inicio =mano_ref.cartas.size()
	_crear_boton_saltar()
	_mostrar_paso()

func _mostrar_paso() -> void:
	texto.text= textos_pasos[paso_actual]
	indicador.text =str(paso_actual + 1) + "/9"
	
	var r: Rect2= rects_pasos[paso_actual]
	recuadro.position= r.position - Vector2(8, 8)
	recuadro.size =r.size + Vector2(16, 16)
	
	texto.position =textos_pos[paso_actual]
	texto.size= Vector2(400, 140)
	
	flecha.visible= _paso_necesita_flecha()
	if flecha.visible:
		flecha.position =Vector2(r.get_center().x - 15, r.position.y - 35)
	
	match paso_actual:
		Paso.BIENVENIDA, Paso.VER_STATS, Paso.ESTRELLAS, Paso.BATALLA, Paso.FIN:
			esperando_accion= false
			fondo.color =Color(0, 0, 0, 0.75)
			fondo.mouse_filter= Control.MOUSE_FILTER_STOP
			get_tree().paused= true
		Paso.COLOCAR_CARTA:
			esperando_accion =true
			fondo.color= Color(0, 0, 0, 0.4)
			fondo.mouse_filter =Control.MOUSE_FILTER_IGNORE
			get_tree().paused= false
			mano_ref.estrellas= 5
			mano_ref.estrellas_max =5
			mano_ref._actualizar_label()
		_:
			esperando_accion= true
			fondo.color =Color(0, 0, 0, 0.4)
			fondo.mouse_filter= Control.MOUSE_FILTER_IGNORE
			get_tree().paused =false

func _paso_necesita_flecha() -> bool:
	return paso_actual in [Paso.VER_MANO, Paso.COLOCAR_CARTA, Paso.PASAR_TURNO]

func _input(event: InputEvent) -> void:
	if !activo:
		return
	
	if !esperando_accion:
		if event is InputEventMouseButton and event.pressed and event.button_index ==MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			_avanzar()
			return

func _process(_delta: float) -> void:
	if !activo or !esperando_accion:
		return
	
	match paso_actual:
		Paso.VER_MANO:
			if Carta.y_oculto <50.0:
				_completar_accion()
		Paso.VOLTEAR_CARTA:
			if mano_ref and mano_ref.cartas.size() >0:
				for carta in mano_ref.cartas:
					if !carta.frente_visible:
						_completar_accion()
						return
		Paso.COLOCAR_CARTA:
			for slot in get_tree().get_nodes_in_group("slots"):
				if slot.carta_actual !=null:
					_completar_accion()
					return
		Paso.PASAR_TURNO:
			if !ManoEnemigo.es_turno_jugador:
				_completar_accion()

func _completar_accion() -> void:
	esperando_accion= false
	await get_tree().create_timer(0.8).timeout
	_avanzar()

func _avanzar() -> void:
	paso_actual +=1
	if paso_actual > Paso.FIN:
		_finalizar()
	else:
		_mostrar_paso()

func _finalizar() -> void:
	activo= false
	visible =false
	get_tree().paused= false
	tutorial_finalizado.emit()

func _crear_boton_saltar() -> void:
	var btn= Button.new()
	btn.text= "SALTAR"
	btn.position= Vector2(1020, 10)
	btn.custom_minimum_size= Vector2(100, 35)
	var style= StyleBoxFlat.new()
	style.bg_color= Color(0.2, 0.2, 0.2, 0.8)
	style.set_corner_radius_all(5)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	btn.add_theme_font_size_override("font_size", 14)
	btn.pressed.connect(_saltar_tutorial)
	add_child(btn)

func _saltar_tutorial() -> void:
	activo= false
	visible= false
	get_tree().paused= false
	Transicion.cambiar_escena("res://Escenas/Cuartos.tscn")
