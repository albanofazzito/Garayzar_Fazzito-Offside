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
@export var boton_turno: TextureButton
@export var label_estrellas_enemigo: Label
var mano: Mano
var tex_mi_turno= preload("res://Sprites/Iconos/pelotaVerde-removebg-preview.png")
var tex_rival= preload("res://Sprites/Iconos/pelota-removebg-preview.png")
var tex_batalla= preload("res://Sprites/Iconos/pelotaAzul-removebg-preview.png")
var estrellas:int= 1
var estrellas_max: int =1
static var es_turno_jugador: bool =true

var angulo_mano: float =20.0
var espaciado_mano: float= 80.0

var _banderas: Dictionary= {
	JugadorData.Pais.ARGENTINA: preload("res://Sprites/Paises/Argentina/Bandera/banderaArgentina.png"),
	JugadorData.Pais.BRASIL: preload("res://Sprites/Paises/Brasil/Bandera/banderaBrasil.png"),
	JugadorData.Pais.FRANCIA: preload("res://Sprites/Paises/Francia/Bandera/banderaFrancia.png"),
	JugadorData.Pais.PORTUGAL: preload("res://Sprites/Paises/Portugal/Bandera/banderaPortugal.png"),
}

var sfx_whistle: AudioStreamPlayer

func _ready() -> void:
	add_to_group("mano_enemigo")
	mano= get_parent().get_node("ManoJugador/Mano") as Mano
	_actualizar_boton()
	_actualizar_label_estrellas()
	sfx_whistle =AudioStreamPlayer.new()
	sfx_whistle.stream= load("res://Audio/whistle.wav")
	sfx_whistle.volume_db= -14.0
	add_child(sfx_whistle)

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
			if datos == null:
				continue
			if datos.pais== p or (datos is TrucoData and datos.es_universal):
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
	carta.datos= load(ruta).duplicate()
	if carta.datos is TrucoData and carta.datos.es_universal and carta.datos.bandera== null:
		carta.datos.bandera= _banderas.get(pais)
		carta.actualizar_carta()
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
	await get_tree().create_timer(0.8).timeout
	match pais:
		JugadorData.Pais.FRANCIA:
			await _turno_francia()
		JugadorData.Pais.BRASIL:
			await _turno_brasil()
		JugadorData.Pais.PORTUGAL:
			await _turno_portugal()
		JugadorData.Pais.ARGENTINA:
			await _turno_argentina()
		_:
			await _turno_basico()

func _turno_francia() -> void:
	var slots_prioridad= _slots_vacios_por_columna([0, 1, 2, 3, 4])
	var cartas_ordenadas= _cartas_jugador_por_stat("stat_ataque", false)
	for slot in slots_prioridad:
		for carta in cartas_ordenadas:
			if carta not in cartas_en_mano:
				continue
			var datos= carta.datos
			if datos is JugadorData and _puede_ir(datos, slot) and datos.estrellas <= estrellas:
				await _colocar_carta(carta, slot)
				await get_tree().create_timer(0.7).timeout
				break

func _turno_brasil() -> void:
	var trucos= _cartas_truco()
	for truco in trucos:
		if truco.datos.estrellas <= estrellas:
			var columna= _mejor_columna_truco(truco.datos)
			if columna >= 0:
				await _jugar_truco_enemigo(truco, columna)
				await get_tree().create_timer(0.9).timeout
				break
	var slots_vacios= _slots_vacios_por_columna([0, 1, 2, 3, 4])
	var cartas_baratas= _cartas_jugador_por_stat("estrellas", true)
	var max_gastar= max(1, estrellas / 2) if estrellas_max < 4 else estrellas
	var gastado= 0
	for slot in slots_vacios:
		for carta in cartas_baratas:
			if carta not in cartas_en_mano:
				continue
			var datos= carta.datos
			if datos is JugadorData and _puede_ir(datos, slot) and datos.estrellas <= estrellas:
				if gastado + datos.estrellas > max_gastar and estrellas_max < 4:
					break
				await _colocar_carta(carta, slot)
				gastado += datos.estrellas
				await get_tree().create_timer(0.7).timeout
				break

func _turno_portugal() -> void:
	var slots_jugador= get_tree().get_nodes_in_group("slots")
	var columnas_amenaza: Array= []
	for slot in slots_jugador:
		if slot.carta_actual != null:
			columnas_amenaza.append(slot.columna)
	var trucos= _cartas_truco()
	for col in columnas_amenaza:
		for truco in trucos:
			if truco.datos.estrellas <= estrellas:
				if _truco_util_en_columna(truco.datos, col):
					await _jugar_truco_enemigo(truco, col)
					await get_tree().create_timer(0.9).timeout
					trucos.erase(truco)
					break
	var slots_enemigo= get_tree().get_nodes_in_group("slots_enemigo")
	var slots_prioridad: Array= []
	for slot in slots_enemigo:
		if slot.carta_actual == null and slot.columna in columnas_amenaza:
			slots_prioridad.append(slot)
	for slot in slots_enemigo:
		if slot.carta_actual == null and slot not in slots_prioridad:
			slots_prioridad.append(slot)
	var cartas_ordenadas= _cartas_jugador_por_stat("stat_ataque", false)
	for slot in slots_prioridad:
		for carta in cartas_ordenadas:
			if carta not in cartas_en_mano:
				continue
			var datos= carta.datos
			if datos is JugadorData and _puede_ir(datos, slot) and datos.estrellas <= estrellas:
				await _colocar_carta(carta, slot)
				await get_tree().create_timer(0.7).timeout
				break

func _turno_argentina() -> void:
	var messi: Carta= null
	for carta in cartas_en_mano:
		if carta.datos is JugadorData and not carta.datos is TrucoData:
			if "MESSI" in carta.datos.info.to_upper():
				messi= carta
				break
	if messi != null and messi.datos.estrellas <= estrellas:
		var slots_vacios= _slots_vacios_por_columna([4, 3, 2, 1, 0])
		for slot in slots_vacios:
			if _puede_ir(messi.datos, slot):
				await _colocar_carta(messi, slot)
				await get_tree().create_timer(0.7).timeout
				break
	if estrellas >= 3:
		var trucos= _cartas_truco()
		for truco in trucos:
			if truco.datos.estrellas <= estrellas:
				var columna= _mejor_columna_truco(truco.datos)
				if columna >= 0:
					await _jugar_truco_enemigo(truco, columna)
					await get_tree().create_timer(0.9).timeout
					break
	var cartas_baratas= _cartas_jugador_por_stat("estrellas", true)
	var slots_vacios= _slots_vacios_por_columna([0, 1, 2, 3, 4])
	for slot in slots_vacios:
		for carta in cartas_baratas:
			if carta not in cartas_en_mano:
				continue
			var datos= carta.datos
			if datos is JugadorData and _puede_ir(datos, slot) and datos.estrellas <= estrellas:
				await _colocar_carta(carta, slot)
				await get_tree().create_timer(0.7).timeout
				break

func _turno_basico() -> void:
	for slot in get_tree().get_nodes_in_group("slots_enemigo"):
		if slot.carta_actual == null:
			var coloco= await _intentar_colocar(slot)
			if coloco:
				await get_tree().create_timer(0.8).timeout

func _intentar_colocar(slot: Slot) -> bool:
	for i in cartas_en_mano.size():
		var carta= cartas_en_mano[i]
		var datos= carta.datos
		if datos is JugadorData and _puede_ir(datos, slot) and datos.estrellas <= estrellas:
			await _colocar_carta(carta, slot)
			return true
	return false

func _cartas_jugador_por_stat(stat: String, ascendente: bool) -> Array:
	var jugadores: Array= []
	for carta in cartas_en_mano:
		if carta.datos is JugadorData and not carta.datos is TrucoData:
			jugadores.append(carta)
	jugadores.sort_custom(func(a, b):
		if ascendente:
			return a.datos[stat] < b.datos[stat]
		else:
			return a.datos[stat] > b.datos[stat]
	)
	return jugadores

func _cartas_truco() -> Array:
	var trucos: Array= []
	for carta in cartas_en_mano:
		if carta.datos is TrucoData:
			trucos.append(carta)
	return trucos

func _slots_vacios_por_columna(orden: Array) -> Array:
	var resultado: Array= []
	var slots= get_tree().get_nodes_in_group("slots_enemigo")
	for col in orden:
		for slot in slots:
			if slot.columna == col and slot.carta_actual == null:
				resultado.append(slot)
	return resultado

func _mejor_columna_truco(datos: TrucoData) -> int:
	match datos.tipo_efecto:
		TrucoData.TipoEfecto.EXPULSAR_CARTA_ENEMIGA:
			var mejor_col= -1
			var mejor_ataque= 0
			for slot in get_tree().get_nodes_in_group("slots"):
				if slot.carta_actual != null:
					var atq= slot.carta_actual.datos.stat_ataque
					if atq > mejor_ataque:
						mejor_ataque= atq
						mejor_col= slot.columna
			return mejor_col
		TrucoData.TipoEfecto.BUFF_ATAQUE_COLUMNA, TrucoData.TipoEfecto.BUFF_VIDA_COLUMNA, TrucoData.TipoEfecto.BUFF_ATAQUE_JUGADOR:
			for slot in get_tree().get_nodes_in_group("slots_enemigo"):
				if slot.carta_actual != null:
					return slot.columna
		TrucoData.TipoEfecto.DANIO_DIRECTO:
			for slot in get_tree().get_nodes_in_group("slots"):
				if slot.carta_actual == null:
					return slot.columna
			return 0
		TrucoData.TipoEfecto.BUFF_ALL_STATS:
			for slot in get_tree().get_nodes_in_group("slots_enemigo"):
				if slot.carta_actual != null:
					return 0
			return -1
		TrucoData.TipoEfecto.ATAQUE_DOBLE_COLUMNA:
			for slot in get_tree().get_nodes_in_group("slots"):
				if slot.carta_actual != null:
					return 0
			return -1
		TrucoData.TipoEfecto.INMUNIDAD_ARCO:
			return 0
		TrucoData.TipoEfecto.EXPULSAR_BARATOS:
			for slot in get_tree().get_nodes_in_group("slots"):
				if slot.carta_actual != null and slot.carta_actual.datos.estrellas < datos.valor:
					return 0
			return -1
		TrucoData.TipoEfecto.CURAR_VIDA:
			return 0
		TrucoData.TipoEfecto.DANIO_DIRECTO_PASANTE:
			for slot in get_tree().get_nodes_in_group("slots_enemigo"):
				if slot.carta_actual != null:
					return slot.columna
			return -1
		TrucoData.TipoEfecto.DANIO_ARCO_DIRECTO:
			return 0
		TrucoData.TipoEfecto.BUFF_VELOCIDAD_COLUMNA:
			for slot in get_tree().get_nodes_in_group("slots_enemigo"):
				if slot.carta_actual != null:
					return slot.columna
			return -1
		TrucoData.TipoEfecto.REDUCIR_VIDA_COLUMNA:
			var mejor_col= -1
			var mejor_vida= 0
			for slot in get_tree().get_nodes_in_group("slots"):
				if slot.carta_actual != null:
					var v= slot.carta_actual.datos.stat_vida
					if v > mejor_vida:
						mejor_vida= v
						mejor_col= slot.columna
			return mejor_col
		TrucoData.TipoEfecto.BUFF_ATAQUE_ALL:
			for slot in get_tree().get_nodes_in_group("slots_enemigo"):
				if slot.carta_actual != null:
					return 0
			return -1
		TrucoData.TipoEfecto.DEBUFF_ATAQUE_ALL:
			for slot in get_tree().get_nodes_in_group("slots"):
				if slot.carta_actual != null:
					return 0
			return -1
	return -1

func _truco_util_en_columna(datos: TrucoData, col: int) -> bool:
	match datos.tipo_efecto:
		TrucoData.TipoEfecto.EXPULSAR_CARTA_ENEMIGA:
			var slot= _get_slot_por_columna(col, "slots")
			return slot != null and slot.carta_actual != null
		TrucoData.TipoEfecto.BUFF_ATAQUE_COLUMNA, TrucoData.TipoEfecto.BUFF_VIDA_COLUMNA, TrucoData.TipoEfecto.BUFF_ATAQUE_JUGADOR:
			var slot= _get_slot_por_columna(col, "slots_enemigo")
			return slot != null and slot.carta_actual != null
		TrucoData.TipoEfecto.DANIO_DIRECTO, TrucoData.TipoEfecto.DANIO_DIRECTO_PASANTE:
			return true
		TrucoData.TipoEfecto.BUFF_ALL_STATS, TrucoData.TipoEfecto.INMUNIDAD_ARCO, TrucoData.TipoEfecto.CURAR_VIDA:
			return true
		TrucoData.TipoEfecto.ATAQUE_DOBLE_COLUMNA:
			return true
		TrucoData.TipoEfecto.EXPULSAR_BARATOS:
			for slot in get_tree().get_nodes_in_group("slots"):
				if slot.carta_actual != null and slot.carta_actual.datos.estrellas < datos.valor:
					return true
			return false
		TrucoData.TipoEfecto.DANIO_ARCO_DIRECTO:
			return true
		TrucoData.TipoEfecto.BUFF_VELOCIDAD_COLUMNA:
			var slot2= _get_slot_por_columna(col, "slots_enemigo")
			return slot2 != null and slot2.carta_actual != null
		TrucoData.TipoEfecto.REDUCIR_VIDA_COLUMNA:
			var slot3= _get_slot_por_columna(col, "slots")
			return slot3 != null and slot3.carta_actual != null
		TrucoData.TipoEfecto.BUFF_ATAQUE_ALL, TrucoData.TipoEfecto.DEBUFF_ATAQUE_ALL:
			return true
	return false

func _get_slot_por_columna(col: int, grupo: String) -> Slot:
	for slot in get_tree().get_nodes_in_group(grupo):
		if slot.columna == col:
			return slot
	return null

func _colocar_carta(carta: Carta, slot: Slot) -> void:
	cartas_en_mano.erase(carta)
	carta.en_mano =false
	carta.z_index= -1
	carta.scale =Vector2(0.6, 0.6)
	carta.rotation= 0.0
	carta.get_node("Base").visible= true
	carta.get_node("BaseTruco").visible= false
	carta.get_node("BaseAtras").visible= false
	carta.frente_visible =true
	var destino= to_local(slot.get_global_rect().get_center())
	carta.posicion_original =destino
	carta.rotacion_original= 0.0
	carta.animar(destino, 0.0)
	slot.carta_actual= carta
	slot.ocultar_visual()
	mano.sfx_woosh2.play()
	estrellas -= carta.datos.estrellas
	_actualizar_label_estrellas()
	_ordenar_mano()

func _jugar_truco_enemigo(carta: Carta, columna: int) -> void:
	cartas_en_mano.erase(carta)
	carta.en_mano= false
	carta.z_index= 5
	carta.scale= Vector2(0.6, 0.6)
	carta.rotation= 0.0
	carta.get_node("Base").visible= false
	carta.get_node("BaseTruco").visible= true
	carta.get_node("BaseAtras").visible= false
	carta.frente_visible= true
	var viewport_size= get_viewport().get_visible_rect().size
	var centro= to_local(Vector2(viewport_size.x / 2.0, viewport_size.y / 2.0))
	carta.position= centro
	var tw= carta.create_tween()
	tw.tween_property(carta, "scale", Vector2(0.8, 0.8), 0.15).set_trans(Tween.TRANS_BACK)
	await tw.finished
	await _esperar_click()
	var tw2= carta.create_tween()
	tw2.tween_property(carta, "scale", Vector2(0.0, 0.0), 0.2)
	tw2.parallel().tween_property(carta, "modulate:a", 0.0, 0.2)
	await tw2.finished
	var datos= carta.datos as TrucoData
	estrellas -= datos.estrellas
	_actualizar_label_estrellas()
	_aplicar_truco(datos, columna)
	carta.queue_free()
	_ordenar_mano()

func _esperar_click() -> void:
	var clicked= false
	while !clicked:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			clicked= true

func _aplicar_truco(datos: TrucoData, columna: int) -> void:
	match datos.tipo_efecto:
		TrucoData.TipoEfecto.EXPULSAR_CARTA_ENEMIGA:
			_expulsar_del_slot(columna, "slots")
		TrucoData.TipoEfecto.EXPULSAR_CARTA_PROPIA:
			_expulsar_del_slot(columna, "slots_enemigo")
		TrucoData.TipoEfecto.BUFF_ATAQUE_COLUMNA:
			_buff_slot(columna, "slots_enemigo", "stat_ataque", datos.valor)
		TrucoData.TipoEfecto.BUFF_VIDA_COLUMNA:
			_buff_slot(columna, "slots_enemigo", "stat_vida", datos.valor)
		TrucoData.TipoEfecto.DANIO_DIRECTO:
			_danio_slot(columna, datos.valor)
		TrucoData.TipoEfecto.ROBAR_CARTAS:
			for i in datos.valor:
				_robar_carta()
		TrucoData.TipoEfecto.BUFF_ALL_STATS:
			_buff_all_stats("slots_enemigo", datos.valor)
		TrucoData.TipoEfecto.ATAQUE_DOBLE_COLUMNA:
			_ataque_doble_columna(datos.valor)
		TrucoData.TipoEfecto.INMUNIDAD_ARCO:
			var vida= get_tree().get_first_node_in_group("vida_enemigo")
			if vida:
				vida.inmune= true
		TrucoData.TipoEfecto.EXPULSAR_BARATOS:
			_expulsar_baratos_jugador(datos.valor)
		TrucoData.TipoEfecto.BUFF_ATAQUE_JUGADOR:
			_buff_slot(columna, "slots_enemigo", "stat_ataque", datos.valor)
		TrucoData.TipoEfecto.CURAR_VIDA:
			var vida= get_tree().get_first_node_in_group("vida_enemigo")
			if vida:
				vida.curar(datos.valor)
		TrucoData.TipoEfecto.DANIO_DIRECTO_PASANTE:
			_danio_pasante(columna)
		TrucoData.TipoEfecto.DANIO_ARCO_DIRECTO:
			var vida_j= get_tree().get_first_node_in_group("vida_jugador")
			if vida_j:
				vida_j.recibir_danio(datos.valor)
		TrucoData.TipoEfecto.BUFF_VELOCIDAD_COLUMNA:
			_buff_slot(columna, "slots_enemigo", "stat_velocidad", datos.valor)
		TrucoData.TipoEfecto.REDUCIR_VIDA_COLUMNA:
			_reducir_vida_slot(columna)
		TrucoData.TipoEfecto.BUFF_ATAQUE_ALL:
			_buff_ataque_all_enemigo(datos.valor)
		TrucoData.TipoEfecto.DEBUFF_ATAQUE_ALL:
			_debuff_ataque_all_jugador(datos.valor)

func _expulsar_del_slot(columna: int, grupo: String) -> void:
	var slot= _get_slot_por_columna(columna, grupo)
	if slot == null or slot.carta_actual == null:
		for s in get_tree().get_nodes_in_group(grupo):
			if s.carta_actual != null and s.carta_actual.datos.efecto_tipo !=JugadorData.EfectoJugador.NO_TRUCOS:
				slot= s
				break
	if slot == null or slot.carta_actual == null:
		return
	if slot.carta_actual.datos.efecto_tipo ==JugadorData.EfectoJugador.NO_TRUCOS:
		return
	var carta= slot.carta_actual
	slot.carta_actual= null
	slot.mostrar_visual()
	var tw= carta.create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tw.tween_property(carta, "modulate", Color(1.0, 0.3, 0.3), 0.08)
	tw.parallel().tween_property(carta, "rotation", deg_to_rad(25.0), 0.12)
	tw.tween_property(carta, "position", carta.position + Vector2(0, -120), 0.2)
	tw.parallel().tween_property(carta, "scale", Vector2(0.18, 0.18), 0.2)
	tw.parallel().tween_property(carta, "modulate:a", 0.0, 0.18)
	await tw.finished
	carta.queue_free()

func _buff_slot(columna: int, grupo: String, stat: String, valor: int) -> void:
	var slot= _get_slot_por_columna(columna, grupo)
	if slot == null or slot.carta_actual == null:
		return
	var carta= slot.carta_actual
	carta.datos[stat] += valor
	if stat == "stat_vida" and carta.combate_inicializado:
		carta.vida_actual += valor
	carta.actualizar_carta()
	var tw= carta.create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(carta, "modulate", Color(0.3, 1.0, 0.5), 0.08)
	tw.parallel().tween_property(carta, "scale", Vector2(0.69, 0.69), 0.1)
	tw.tween_property(carta, "scale", Vector2(0.6, 0.6), 0.12)
	tw.parallel().tween_property(carta, "modulate", Color.WHITE, 0.2)

func _danio_slot(columna: int, valor: int) -> void:
	var slot= _get_slot_por_columna(columna, "slots")
	if slot != null and slot.carta_actual != null:
		if slot.carta_actual.datos.efecto_tipo ==JugadorData.EfectoJugador.NO_TRUCOS:
			return
		slot.carta_actual.recibir_danio(valor)
		if !slot.carta_actual.esta_viva():
			var carta= slot.carta_actual
			slot.carta_actual= null
			slot.mostrar_visual()
			carta.queue_free()
		else:
			slot.carta_actual.actualizar_carta()

func _buff_all_stats(grupo: String, valor: int) -> void:
	for slot in get_tree().get_nodes_in_group(grupo):
		if slot.carta_actual != null:
			slot.carta_actual.datos.stat_ataque += valor
			slot.carta_actual.datos.stat_velocidad += valor
			slot.carta_actual.datos.stat_vida += valor
			if slot.carta_actual.combate_inicializado:
				slot.carta_actual.vida_actual += valor
			slot.carta_actual.actualizar_carta()

func _ataque_doble_columna(perdida_vida: int) -> void:
	var columnas= [0, 1, 2, 3, 4]
	columnas.shuffle()
	var atacadas= columnas.slice(0, 2)
	for col in atacadas:
		var slot= _get_slot_por_columna(col, "slots")
		if slot != null and slot.carta_actual != null and slot.carta_actual.datos.efecto_tipo !=JugadorData.EfectoJugador.NO_TRUCOS:
			slot.carta_actual.recibir_danio(perdida_vida)
			if !slot.carta_actual.esta_viva():
				var carta= slot.carta_actual
				slot.carta_actual= null
				slot.mostrar_visual()
				carta.queue_free()
			else:
				slot.carta_actual.actualizar_carta()

func _expulsar_baratos_jugador(costo_max: int) -> void:
	for slot in get_tree().get_nodes_in_group("slots"):
		if slot.carta_actual != null and slot.carta_actual.datos.estrellas < costo_max and slot.carta_actual.datos.efecto_tipo !=JugadorData.EfectoJugador.NO_TRUCOS:
			var carta= slot.carta_actual
			slot.carta_actual= null
			slot.mostrar_visual()
			var tw= carta.create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
			tw.tween_property(carta, "modulate", Color(1.0, 0.3, 0.3), 0.08)
			tw.tween_property(carta, "position", carta.position + Vector2(0, -120), 0.2)
			tw.parallel().tween_property(carta, "scale", Vector2(0.18, 0.18), 0.2)
			tw.parallel().tween_property(carta, "modulate:a", 0.0, 0.18)

func _danio_pasante(columna: int) -> void:
	var slot_enemigo= _get_slot_por_columna(columna, "slots_enemigo")
	if slot_enemigo == null or slot_enemigo.carta_actual == null:
		for s in get_tree().get_nodes_in_group("slots_enemigo"):
			if s.carta_actual != null:
				slot_enemigo= s
				break
	if slot_enemigo == null or slot_enemigo.carta_actual == null:
		return
	var danio= slot_enemigo.carta_actual.datos.stat_ataque
	var vida= get_tree().get_first_node_in_group("vida_jugador")
	if vida:
		vida.recibir_danio(danio)

func _reducir_vida_slot(columna: int) -> void:
	var slot= _get_slot_por_columna(columna, "slots")
	if slot== null or slot.carta_actual== null:
		for s in get_tree().get_nodes_in_group("slots"):
			if s.carta_actual !=null and s.carta_actual.datos.efecto_tipo !=JugadorData.EfectoJugador.NO_TRUCOS:
				slot =s
				break
	if slot== null or slot.carta_actual== null:
		return
	if slot.carta_actual.datos.efecto_tipo ==JugadorData.EfectoJugador.NO_TRUCOS:
		return
	slot.carta_actual.recibir_danio(30)
	if !slot.carta_actual.esta_viva():
		var carta= slot.carta_actual
		slot.carta_actual= null
		slot.mostrar_visual()
		carta.queue_free()
	else:
		slot.carta_actual.actualizar_carta()

func _buff_ataque_all_enemigo(valor: int) -> void:
	for slot in get_tree().get_nodes_in_group("slots_enemigo"):
		if slot.carta_actual !=null:
			slot.carta_actual.datos.stat_ataque +=valor
			slot.carta_actual.actualizar_carta()

func _debuff_ataque_all_jugador(valor: int) -> void:
	for slot in get_tree().get_nodes_in_group("slots"):
		if slot.carta_actual !=null and slot.carta_actual.datos.efecto_tipo !=JugadorData.EfectoJugador.NO_TRUCOS:
			slot.carta_actual.datos.stat_ataque =max(0, slot.carta_actual.datos.stat_ataque - valor)
			slot.carta_actual.actualizar_carta()

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
	if mano.en_tutorial and get_parent().has_node("Tutorial"):
		var tut= get_parent().get_node("Tutorial")
		if tut.activo and tut.paso_actual < tut.Paso.PASAR_TURNO:
			return
	_animar_boton()
	estado= Estado.ESPERANDO_BATALLA
	es_turno_jugador =false
	_actualizar_boton()
	boton_turno.disabled =true
	await jugar_turno()
	await get_tree().create_timer(1.0).timeout
	estado =Estado.BATALLANDO
	_actualizar_boton()
	_animar_boton()
	batalla_manager.iniciar_batalla()


func _on_batalla_manager_batalla_terminada() -> void:
	estado= Estado.TURNO_JUGADOR
	es_turno_jugador =true
	_actualizar_boton()
	_animar_boton()
	boton_turno.disabled= false
	mano.sumar_estrella()
	sumar_estrella()
	_aplicar_mejor_representante()
	if mano.cartas.size() <mano.cartas_max:
		mano.agregar()
	_robar_carta()
	sfx_whistle.play()


func _actualizar_boton() -> void:
	if !boton_turno:
		return
	match estado:
		Estado.TURNO_JUGADOR:
			boton_turno.texture_normal= tex_mi_turno
		Estado.ESPERANDO_BATALLA:
			boton_turno.texture_normal= tex_rival
		Estado.BATALLANDO:
			boton_turno.texture_normal= tex_batalla

func _aplicar_mejor_representante() -> void:
	for carta in mano.cartas:
		if carta.datos.efecto_tipo ==JugadorData.EfectoJugador.MEJOR_REPRESENTANTE:
			if carta.datos.estrellas > 1:
				carta.datos.estrellas -=1
				carta.get_node("Base/RecipienteEstrellas/Coste").text =str(carta.datos.estrellas)
	for carta in cartas_en_mano:
		if carta.datos.efecto_tipo ==JugadorData.EfectoJugador.MEJOR_REPRESENTANTE:
			if carta.datos.estrellas > 1:
				carta.datos.estrellas -=1

func _animar_boton() -> void:
	if !boton_turno:
		return
	var tw= create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(boton_turno, "scale", Vector2(0.5, 0.5), 0.08).set_trans(Tween.TRANS_SINE)
	tw.tween_property(boton_turno, "rotation", boton_turno.rotation + TAU, 0.3).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(boton_turno, "scale", Vector2(1.3, 1.3), 0.15)
	tw.tween_property(boton_turno, "scale", Vector2(1.0, 1.0), 0.2)

func _actualizar_label_estrellas() -> void:
	if !label_estrellas_enemigo:
		return
	label_estrellas_enemigo.text =str(estrellas) + "/" + str(estrellas_max)
