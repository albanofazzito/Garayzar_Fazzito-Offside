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
var turnos_en_campo: int =0
var esquivar_contador: int= 0
var kante_usado: bool= false
var saliba_activado: bool= false
var combate_inicializado: bool= false


var COLORES_CALIDAD = {
	JugadorData.Calidad.BRONCE: Color("#993024"), 
	JugadorData.Calidad.PLATA: Color("#978f87"), 
	JugadorData.Calidad.ORO: Color("#d19700"), 
	JugadorData.Calidad.CAPITAN: Color("#00c2d1")
}
var posiciones = ["ARQUERO", "DEFENSOR", "MEDIOCAMPISTA", "DELANTERO","TODO"]
var paises = ["ARGENTINA", "BRASIL", "FRANCIA", "INGLATERRA", "ALEMANIA", "HOLANDA", "ESPANA", "PORTUGAL"]

@export var datos: Resource:
	set(value):
		datos =value.duplicate() if value else null
		if is_node_ready():
			actualizar_carta()

func actualizar_carta():
	var es_truco= datos is TrucoData
	var texto_pais = _texto_pais(datos.pais)
	$BaseTruco.visible=es_truco
	$Base.visible=!es_truco
	$Base/Jugador.texture =datos.foto
	$Base/InfoJugador.text= datos.info
	$Base/InfoJugadorBorde.text= datos.info
	$Base/Stats/CajaAtaque/NumeroAtaque.text= str(datos.stat_ataque)
	$Base/Stats/CajaVelocidad/NumeroVelocidad.text =str(datos.stat_velocidad)
	$Base/Stats/CajaDefensa/NumeroDefensa.text= str(datos.stat_vida)
	$Base/RecipienteEstrellas/Coste.text =str(datos.estrellas)
	$BaseAtras/Bandera.texture= datos.bandera
	$BaseAtras/CajaEfecto/Efecto.text ="[center]" + datos.efecto + "[/center]"
	$Base/PaisJugador.text= texto_pais
	$Base/PaisJugadorBorde.text= texto_pais
	$Base/Posicion.text= _texto_posicion(datos.posicion)
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

func _texto_pais(pais) -> String:
	if typeof(pais) == TYPE_INT and pais >= 0 and pais < paises.size():
		return paises[pais]
	return str(pais)

func _texto_posicion(posicion) -> String:
	if typeof(posicion) == TYPE_INT and posicion >= 0 and posicion < posiciones.size():
		return posiciones[posicion]
	return str(posicion)

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

		if datos is TrucoData and ManoEnemigo.es_turno_jugador and datos.estrellas <= get_parent().estrellas:
			var columna :=-1
			for slot in get_tree().get_nodes_in_group("slots"):
				if slot.get_global_rect().has_point(mouse_pos):
					columna =slot.columna
					break
			if columna ==-1:
				for slot in get_tree().get_nodes_in_group("slots_enemigo"):
					if slot.get_global_rect().has_point(mouse_pos):
						columna =slot.columna
						break
			var necesita= get_parent().efecto_manager.necesita_columna(datos)
			if columna >=0 or !necesita:
				get_parent().jugar_truco(self, columna)
				get_viewport().set_input_as_handled()
				return

		var slot_encontrado: Slot =null
		for slot in get_tree().get_nodes_in_group("slots"):
			if slot.get_global_rect().has_point(mouse_pos):
				slot_encontrado =slot
				break
		if slot_encontrado and slot_encontrado.carta_actual ==null and _puede_ir_en_slot(slot_encontrado) and datos.estrellas <= get_parent().estrellas and ManoEnemigo.es_turno_jugador:
			get_parent().gastar_estrellas(datos.estrellas)
			slot_encontrado.carta_actual =self
			slot_encontrado.ocultar_visual()
			en_mano =false
			z_index =-1
			get_parent().cartas.erase(self)
			get_parent().orden()
			get_parent().sfx_woosh2.play()
			var destino =get_parent().to_local(slot_encontrado.get_global_rect().get_center())
			posicion_original =destino
			rotacion_original =0.0
			animar(destino, 0.0)
		else:
			animar(Vector2(posicion_original.x, posicion_original.y + y_oculto), rotacion_original)
		get_viewport().set_input_as_handled()
		return

	const UMBRAL_VISIBLE :=150.0
	if y_oculto > UMBRAL_VISIBLE:
		return

	if not get_parent() is Mano:
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
	if !en_mano:
		z_index =-1
	elif !frente_visible:
		z_index= 10
	else:
		if hover:
			z_index =10
		else:
			z_index =0

func _puede_ir_en_slot(slot: Slot) -> bool:
	if datos.posicion== JugadorData.Posicion.TODO:
		return true
	if datos.efecto_tipo== JugadorData.EfectoJugador.MULTIPOSICION:
		return true
	match slot.columna:
		0:
			return datos.posicion== JugadorData.Posicion.ARQUERO or datos.posicion ==JugadorData.Posicion.DEFENSOR
		1:
			return datos.posicion ==JugadorData.Posicion.DEFENSOR
		2:
			return datos.posicion== JugadorData.Posicion.MEDIOCAMPISTA
		3:
			return datos.posicion ==JugadorData.Posicion.MEDIOCAMPISTA or datos.posicion== JugadorData.Posicion.DELANTERO
		4:
			return datos.posicion ==JugadorData.Posicion.DELANTERO
	return false

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
	if !combate_inicializado:
		vida_actual =datos.stat_vida
		combate_inicializado =true

func recibir_danio(danio: int) -> void:
	var danio_real= danio
	if datos.efecto_tipo ==JugadorData.EfectoJugador.COMPARTIR_DANIO:
		var grupo= _get_mi_grupo()
		var companero: Carta= null
		for slot in get_tree().get_nodes_in_group(grupo):
			if slot.carta_actual != null and slot.carta_actual != self and slot.carta_actual.esta_viva():
				companero= slot.carta_actual
				break
		if companero != null:
			danio_real= max(danio / 2, 1)
			var danio_companero= danio - danio_real
			companero.vida_actual -= danio_companero
			companero.get_node("Base/Stats/CajaDefensa/NumeroDefensa").text =str(max(companero.vida_actual, 0))
	vida_actual -=danio_real
	$Base/Stats/CajaDefensa/NumeroDefensa.text =str(max(vida_actual, 0))
	if tween_color:
		tween_color.kill()
	tween_color =create_tween().set_trans(Tween.TRANS_SINE)
	tween_color.tween_property(self, "modulate", Color(1.0, 0.2, 0.2), 0.06)
	tween_color.tween_property(self, "scale", Vector2(0.54, 0.66), 0.05)
	tween_color.parallel().tween_property(self, "position", position + Vector2(randf_range(-5, 5), 0), 0.03)
	tween_color.tween_property(self, "scale", Vector2(0.6, 0.6), 0.12).set_trans(Tween.TRANS_ELASTIC)
	tween_color.parallel().tween_property(self, "position", position, 0.08)
	tween_color.tween_property(self, "modulate", Color.WHITE, 0.15)

func esta_viva() -> bool:
	return vida_actual > 0

func animar_ataque(objetivo: Carta) -> void:
	var dir =objetivo.global_position - global_position
	var offset =dir.normalized() * 35.0
	var pos_orig =position
	var tw =create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "scale", Vector2(0.69, 0.54), 0.05)
	tw.tween_property(self, "position", position + offset, 0.06).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(0.57, 0.63), 0.03)
	tw.tween_property(self, "position", pos_orig, 0.1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "scale", Vector2(0.6, 0.6), 0.08)
	await tw.finished

func animar_ataque_base() -> void:
	var dir_y =-1 if en_mano == false and get_parent() is ManoEnemigo else 1
	var offset =Vector2(0, dir_y * 45)
	var pos_orig =position
	var tw =create_tween()
	tw.tween_property(self, "scale", Vector2(0.72, 0.51), 0.06).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "position", position + offset, 0.07).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(0.54, 0.66), 0.03)
	tw.tween_property(self, "position", pos_orig, 0.12).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "scale", Vector2(0.6, 0.6), 0.1)
	await tw.finished

func aplicar_efecto_turno() -> void:
	turnos_en_campo +=1
	if datos.efecto_tipo ==JugadorData.EfectoJugador.BUFF_ATAQUE_POR_TURNO:
		datos.stat_ataque +=datos.efecto_valor
		$Base/Stats/CajaAtaque/NumeroAtaque.text =str(datos.stat_ataque)
		var tw= create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "modulate", Color(1.0, 0.9, 0.3), 0.08)
		tw.parallel().tween_property(self, "scale", Vector2(0.67, 0.67), 0.1)
		tw.tween_property(self, "scale", Vector2(0.6, 0.6), 0.2)
		tw.parallel().tween_property(self, "modulate", Color.WHITE, 0.25)
	if datos.efecto_tipo ==JugadorData.EfectoJugador.SINERGIA_HERMANOS:
		var grupo= _get_mi_grupo()
		var hermano_presente= false
		for slot in get_tree().get_nodes_in_group(grupo):
			if slot.carta_actual != null and slot.carta_actual != self:
				if slot.carta_actual.datos.efecto_tipo ==JugadorData.EfectoJugador.SINERGIA_HERMANOS:
					hermano_presente= true
					break
		if hermano_presente and turnos_en_campo ==1:
			datos.stat_ataque +=datos.efecto_valor
			datos.stat_velocidad +=datos.efecto_valor
			datos.stat_vida +=datos.efecto_valor
			vida_actual +=datos.efecto_valor
			actualizar_carta()
			var tw= create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
			tw.tween_property(self, "modulate", Color(0.5, 0.5, 1.0), 0.1)
			tw.parallel().tween_property(self, "scale", Vector2(0.7, 0.7), 0.12)
			tw.tween_property(self, "scale", Vector2(0.6, 0.6), 0.15)
			tw.parallel().tween_property(self, "modulate", Color.WHITE, 0.2)
	if datos.efecto_tipo ==JugadorData.EfectoJugador.BUFF_VIDA_COMPANERO:
		if !saliba_activado:
			var grupo= _get_mi_grupo()
			for slot in get_tree().get_nodes_in_group(grupo):
				if slot.carta_actual != null and slot.carta_actual != self:
					datos.stat_vida +=datos.efecto_valor
					vida_actual +=datos.efecto_valor
					actualizar_carta()
					saliba_activado= true
					break

func aplicar_efecto_post_combate() -> void:
	if datos.efecto_tipo ==JugadorData.EfectoJugador.MATAR_ALEATORIO:
		var todos_slots: Array= []
		for slot in get_tree().get_nodes_in_group("slots"):
			if slot.carta_actual != null and slot.carta_actual != self and slot.carta_actual.datos.efecto_tipo !=JugadorData.EfectoJugador.NO_TRUCOS:
				todos_slots.append(slot)
		for slot in get_tree().get_nodes_in_group("slots_enemigo"):
			if slot.carta_actual != null and slot.carta_actual != self and slot.carta_actual.datos.efecto_tipo !=JugadorData.EfectoJugador.NO_TRUCOS:
				todos_slots.append(slot)
		if todos_slots.size() > 0:
			var slot_random= todos_slots[randi() % todos_slots.size()]
			slot_random.carta_actual.vida_actual= 0
			slot_random.carta_actual.get_node("Base/Stats/CajaDefensa/NumeroDefensa").text= "0"
	if datos.efecto_tipo ==JugadorData.EfectoJugador.DANIO_ARCO_TURNO:
		var grupo_vida= "vida_jugador" if _get_mi_grupo() == "slots_enemigo" else "vida_enemigo"
		var vida= get_tree().get_first_node_in_group(grupo_vida)
		if vida:
			vida.recibir_danio(datos.efecto_valor)

func _get_mi_grupo() -> String:
	for slot in get_tree().get_nodes_in_group("slots"):
		if slot.carta_actual == self:
			return "slots"
	for slot in get_tree().get_nodes_in_group("slots_enemigo"):
		if slot.carta_actual == self:
			return "slots_enemigo"
	return ""

func puede_esquivar() -> bool:
	if datos.efecto_tipo ==JugadorData.EfectoJugador.ESQUIVAR_CADA_2:
		esquivar_contador +=1
		if esquivar_contador >=2:
			esquivar_contador =0
			return true
	return false

func activar_rage(vida_base: int) -> void:
	if datos.efecto_tipo ==JugadorData.EfectoJugador.RAGE_AL_GOL:
		datos.stat_ataque =datos.efecto_valor
		$Base/Stats/CajaAtaque/NumeroAtaque.text =str(datos.stat_ataque)
		var tw =create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "modulate", Color(1.0, 0.0, 0.0), 0.08)
		tw.parallel().tween_property(self, "scale", Vector2(0.75, 0.75), 0.12)
		tw.tween_property(self, "rotation", deg_to_rad(-5.0), 0.06)
		tw.tween_property(self, "rotation", deg_to_rad(5.0), 0.06)
		tw.tween_property(self, "rotation", 0.0, 0.08)
		tw.parallel().tween_property(self, "scale", Vector2(0.6, 0.6), 0.2)
		tw.tween_property(self, "modulate", Color(1.0, 0.6, 0.6), 0.3)
		await tw.finished
