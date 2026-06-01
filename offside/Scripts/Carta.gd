class_name Carta
extends Node2D

var frente_visible: bool = true
var hover: bool = false
var posicion_original: Vector2
var rotacion_original: float
var tween: Tween
var en_mano: bool = true
var rect_original: Rect2 #ahi lo arregle gary
var arrastrando: bool = false
var pos_click_inicial: Vector2
const umbral_arrastre:= 8.0
static var carta_siendo_arrastrada:Carta= null
static var y_oculto: float = 280.0
var vida_actual: int = 0
var tween_color: Tween


var COLORES_CALIDAD = {
	JugadorData.Calidad.BRONCE: Color("#993024"), 
	JugadorData.Calidad.PLATA: Color("#978f87"), 
	JugadorData.Calidad.ORO: Color("#d19700"), 
	JugadorData.Calidad.CAPITAN: Color("#00c2d1")
}
var posiciones = ["ARQUERO", "DEFENSOR", "MEDIOCAMPISTA", "DELANTERO","TODO"]
var paises = ["ARGENTINA", "BRASIL", "FRANCIA", "INGLATERRA", "ALEMANIA", "HOLANDA", "ESPAÑA", "PORTUGAL"]

@export var datos: Resource:
	set(value):
		datos =value
		if is_node_ready():
			actualizar_carta()

func actualizar_carta():
	var es_truco= datos is TrucoData
	$BaseTruco.visible=es_truco
	$Base.visible=!es_truco
	$Base/Jugador.texture =datos.foto
	$Base/InfoJugador.text= datos.info
	$Base/Stats/CajaAtaque/NumeroAtaque.text= str(datos.stat_ataque)
	$Base/Stats/CajaVelocidad/NumeroVelocidad.text =str(datos.stat_velocidad)
	$Base/Stats/CajaDefensa/NumeroDefensa.text= str(datos.stat_vida)
	$Base/RecipienteEstrellas/Coste.text =str(datos.estrellas)
	$BaseAtras/Bandera.texture= datos.bandera
	$BaseAtras/CajaEfecto/Efecto.text =datos.efecto
	$Base/PaisJugador.text= paises[datos.pais]
	$Base/Posicion.text= posiciones[datos.posicion]
	$BaseTruco/Efecto.text= datos.efecto
	$BaseTruco/ImagenTruco.texture =datos.foto
	$BaseTruco/InfoTruco.text=datos.info
	$BaseTruco/RecipienteEstrellas/Coste.text =str(datos.estrellas)
	aplicarCalidad(datos.calidad)

func aplicarCalidad(calidad: JugadorData.Calidad):
	var color= COLORES_CALIDAD[calidad]
	var Panel =$Base
	var Panel2= $BaseAtras
	var estilo =Panel.get_theme_stylebox("panel").duplicate()
	estilo.border_color= color
	Panel.add_theme_stylebox_override("panel", estilo)
	Panel2.add_theme_stylebox_override("panel", estilo)
	$Base/Divisor.color =color

func _input(event: InputEvent) -> void:
	if !en_mano:
		if event is InputEventMouseButton and event.button_index ==MOUSE_BUTTON_RIGHT and event.pressed:
			if $Base.get_global_rect().has_point(event.global_position) or $BaseAtras.get_global_rect().has_point(event.global_position):
				voltear()
				get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseMotion and arrastrando:
		position =get_parent().to_local(event.global_position)
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and !event.pressed and arrastrando:
		arrastrando =false
		hover =false
		z_index =0
		carta_siendo_arrastrada =null
		var mouse_pos =get_viewport().get_mouse_position()
		var slot_encontrado: Slot =null
		for slot in get_tree().get_nodes_in_group("slots"):
			if slot.get_global_rect().has_point(mouse_pos):
				slot_encontrado =slot
				break
		if slot_encontrado and slot_encontrado.carta_actual ==null and slot_encontrado.tipo ==datos.posicion and datos.estrellas <= get_parent().estrellas and ManoEnemigo.es_turno_jugador:
			get_parent().gastar_estrellas(datos.estrellas)
			slot_encontrado.carta_actual =self
			en_mano =false
			z_index =-1
			get_parent().cartas.erase(self)
			get_parent().orden()
			var destino =get_parent().to_local(slot_encontrado.get_global_rect().get_center())
			posicion_original =destino
			rotacion_original =0.0
			animar(destino, 0.0)
		else:
			animar(posicion_original, rotacion_original)
		get_viewport().set_input_as_handled()
		return

	const UMBRAL_VISIBLE :=150.0
	if y_oculto > UMBRAL_VISIBLE:
		return

	if event is InputEventMouseMotion:
		var rect_chequeo =rect_original if hover else $Base.get_global_rect()
		if rect_chequeo.has_point(event.global_position):
			var hay_carta_encima =false
			for carta in get_parent().cartas:
				if carta !=self and carta.z_index > z_index:
					if carta.get_node("Base").get_global_rect().has_point(event.global_position):
						hay_carta_encima =true
						break
			if !hay_carta_encima and !hover:
				hover =true
				rect_original =$Base.get_global_rect()
				z_index =10
				animar(Vector2(posicion_original.x, posicion_original.y + y_oculto - 80.0), 0.0)
		else:
			if hover:
				hover =false
				z_index =0
				animar(Vector2(posicion_original.x, posicion_original.y + y_oculto), rotacion_original)

	if event is InputEventMouseButton:
		if event.button_index ==MOUSE_BUTTON_LEFT and event.pressed:
			if $Base.get_global_rect().has_point(event.global_position):
				var hay_carta_encima =false
				for carta in get_parent().cartas:
					if carta !=self and carta.z_index > z_index:
						if carta.get_node("Base").get_global_rect().has_point(event.global_position):
							hay_carta_encima =true
							break
				if !hay_carta_encima and hover and carta_siendo_arrastrada ==null:
					pos_click_inicial =event.global_position
					get_viewport().set_input_as_handled()
		elif hover:
			voltear()
			get_viewport().set_input_as_handled()

func voltear() -> void:
	frente_visible =!frente_visible
	$Base.visible= frente_visible
	$BaseAtras.visible =!frente_visible
	if !frente_visible:
		z_index= 10
	else:
		if hover:
			z_index =10
		else:
			z_index =0

#usa esto para animar cartas cualquier cosa
func animar(pos_destino: Vector2, rot_destino: float) -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position",pos_destino, 0.2)
	tween.parallel().tween_property(self, "rotation", rot_destino, 0.2)
	
func orden_externo(pos: Vector2, rot: float) -> void:
	posicion_original =pos
	rotacion_original= rot
	if !hover and !arrastrando:
		position =Vector2(pos.x, pos.y + y_oculto)
		rotation =rot
		

func _process(_delta: float) -> void:
	if !en_mano:
		return

	if !arrastrando and hover and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var distancia =get_viewport().get_mouse_position().distance_to(pos_click_inicial)
		if distancia > umbral_arrastre:
			if carta_siendo_arrastrada ==null:
				arrastrando =true
				carta_siendo_arrastrada= self
				hover =false
				z_index =20
				if tween:
					tween.kill()

func inicializar_combate() -> void:
	if vida_actual <=0:
		vida_actual =datos.stat_vida

func recibir_danio(danio: int) -> void:
	vida_actual -=danio
	$Base/Stats/CajaDefensa/NumeroDefensa.text =str(max(vida_actual, 0))
	if tween_color:
		tween_color.kill()
	tween_color =create_tween()
	tween_color.tween_property(self, "modulate", Color.RED, 0.05)
	tween_color.tween_property(self, "modulate", Color.WHITE, 0.15)

func esta_viva() -> bool:
	return vida_actual > 0

func animar_ataque(objetivo: Carta) -> void:
	var dir_y =sign(objetivo.global_position.y - global_position.y)
	var offset =Vector2(0, dir_y * 25)
	var tw =create_tween()
	tw.tween_property(self, "position", position + offset, 0.12)
	tw.tween_property(self, "position", position, 0.12)
	await tw.finished
