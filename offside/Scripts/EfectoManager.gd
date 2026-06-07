class_name EfectoManager
extends Node

func ejecutar(datos: TrucoData, mano: Mano, columna: int) -> void:
	match datos.tipo_efecto:
		TrucoData.TipoEfecto.EXPULSAR_CARTA_ENEMIGA:
			_expulsar_carta(columna, "slots_enemigo", null)
		TrucoData.TipoEfecto.EXPULSAR_CARTA_PROPIA:
			_expulsar_carta(columna, "slots", mano)
		TrucoData.TipoEfecto.BUFF_ATAQUE_COLUMNA:
			_buff_stat(columna, "slots", "stat_ataque", datos.valor)
		TrucoData.TipoEfecto.BUFF_VIDA_COLUMNA:
			_buff_stat(columna, "slots", "stat_vida", datos.valor)
		TrucoData.TipoEfecto.DANIO_DIRECTO:
			_danio_directo(columna, datos.valor)
		TrucoData.TipoEfecto.ROBAR_CARTAS:
			for i in datos.valor:
				if mano.cartas.size() <mano.cartas_max:
					mano.agregar()
		TrucoData.TipoEfecto.BUFF_ALL_STATS:
			_buff_all_stats("slots", datos.valor)
		TrucoData.TipoEfecto.ATAQUE_DOBLE_COLUMNA:
			_ataque_doble_columna("slots", "slots_enemigo", datos.valor)
		TrucoData.TipoEfecto.INMUNIDAD_ARCO:
			_inmunidad_arco("vida_jugador")
		TrucoData.TipoEfecto.EXPULSAR_BARATOS:
			_expulsar_baratos("slots_enemigo", datos.valor)
		TrucoData.TipoEfecto.BUFF_ATAQUE_JUGADOR:
			_buff_ataque_jugador(columna, "slots", datos.valor)
		TrucoData.TipoEfecto.CURAR_VIDA:
			_curar_vida("vida_jugador", datos.valor)
		TrucoData.TipoEfecto.DANIO_DIRECTO_PASANTE:
			_danio_directo_pasante(columna, "slots", "vida_enemigo")
		TrucoData.TipoEfecto.DANIO_ARCO_DIRECTO:
			_danio_arco_directo("vida_enemigo", datos.valor)
		TrucoData.TipoEfecto.BUFF_VELOCIDAD_COLUMNA:
			_buff_stat(columna, "slots", "stat_velocidad", datos.valor)
		TrucoData.TipoEfecto.REDUCIR_VIDA_COLUMNA:
			_reducir_vida_columna(columna, datos.valor)
		TrucoData.TipoEfecto.BUFF_ATAQUE_ALL:
			_buff_ataque_all("slots", datos.valor)
		TrucoData.TipoEfecto.DEBUFF_ATAQUE_ALL:
			_debuff_ataque_all("slots_enemigo", datos.valor)

func necesita_columna(datos: TrucoData) -> bool:
	match datos.tipo_efecto:
		TrucoData.TipoEfecto.EXPULSAR_CARTA_ENEMIGA, TrucoData.TipoEfecto.EXPULSAR_CARTA_PROPIA, TrucoData.TipoEfecto.BUFF_ATAQUE_COLUMNA, TrucoData.TipoEfecto.BUFF_VIDA_COLUMNA, TrucoData.TipoEfecto.DANIO_DIRECTO, TrucoData.TipoEfecto.BUFF_ATAQUE_JUGADOR, TrucoData.TipoEfecto.DANIO_DIRECTO_PASANTE, TrucoData.TipoEfecto.BUFF_VELOCIDAD_COLUMNA, TrucoData.TipoEfecto.REDUCIR_VIDA_COLUMNA:
			return true
		_:
			return false

func _expulsar_carta(columna: int, grupo: String, mano_devolver: Mano) -> void:
	var slot =_get_slot(columna, grupo)
	if slot ==null or slot.carta_actual ==null:
		for s in get_tree().get_nodes_in_group(grupo):
			if s.carta_actual !=null:
				slot =s
				break
	if slot ==null or slot.carta_actual ==null:
		return
	if slot.carta_actual.datos.efecto_tipo ==JugadorData.EfectoJugador.NO_TRUCOS:
		return
	var carta =slot.carta_actual
	slot.carta_actual =null
	slot.mostrar_visual()
	if mano_devolver !=null and carta.datos is JugadorData:
		# Animacion de retorno a la mano
		var tw =carta.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw.tween_property(carta, "scale", Vector2(0.36, 0.36), 0.1)
		tw.parallel().tween_property(carta, "rotation", deg_to_rad(15.0), 0.1)
		tw.tween_property(carta, "modulate:a", 0.0, 0.15)
		await tw.finished
		carta.scale =Vector2(0.6, 0.6)
		carta.rotation =0.0
		carta.modulate.a =1.0
		mano_devolver.cartas.append(carta)
		carta.en_mano =true
		carta.reparent(mano_devolver)
		mano_devolver.orden()
	else:
		# Expulsion con giro y salida hacia arriba
		var tw =carta.create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		tw.tween_property(carta, "modulate", Color(1.0, 0.3, 0.3), 0.08)
		tw.parallel().tween_property(carta, "rotation", deg_to_rad(25.0), 0.12)
		tw.tween_property(carta, "position", carta.position + Vector2(0, -120), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		tw.parallel().tween_property(carta, "scale", Vector2(0.18, 0.18), 0.2)
		tw.parallel().tween_property(carta, "modulate:a", 0.0, 0.18)
		await tw.finished
		carta.queue_free()

func _buff_stat(columna: int, grupo: String, stat: String, valor: int) -> void:
	var slot =_get_slot(columna, grupo)
	if slot ==null or slot.carta_actual ==null:
		return
	var carta =slot.carta_actual
	carta.datos[stat] +=valor
	if stat == "stat_vida" and carta.combate_inicializado:
		carta.vida_actual +=valor
	carta.actualizar_carta()
	var tw =carta.create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(carta, "modulate", Color(0.3, 1.0, 0.5), 0.08)
	tw.parallel().tween_property(carta, "scale", Vector2(0.69, 0.69), 0.1)
	tw.tween_property(carta, "scale", Vector2(0.57, 0.57), 0.08)
	tw.tween_property(carta, "scale", Vector2(0.6, 0.6), 0.12)
	tw.parallel().tween_property(carta, "modulate", Color.WHITE, 0.2)

func _danio_directo(columna: int, valor: int) -> void:
	var slot =_get_slot(columna, "slots_enemigo")
	if slot !=null and slot.carta_actual !=null:
		if slot.carta_actual.datos.efecto_tipo ==JugadorData.EfectoJugador.NO_TRUCOS:
			return
		slot.carta_actual.recibir_danio(valor)
	else:
		var vida =get_tree().get_first_node_in_group("vida_enemigo")
		if vida:
			vida.recibir_danio(valor)

func _get_slot(columna: int, grupo: String):
	if columna <0:
		return null
	for slot in get_tree().get_nodes_in_group(grupo):
		if slot.columna ==columna:
			return slot
	return null

func _buff_all_stats(grupo: String, valor: int) -> void:
	for slot in get_tree().get_nodes_in_group(grupo):
		if slot.carta_actual != null:
			slot.carta_actual.datos.stat_ataque += valor
			slot.carta_actual.datos.stat_velocidad += valor
			slot.carta_actual.datos.stat_vida += valor
			if slot.carta_actual.combate_inicializado:
				slot.carta_actual.vida_actual += valor
			slot.carta_actual.actualizar_carta()
			var tw= slot.carta_actual.create_tween()
			tw.tween_property(slot.carta_actual, "modulate", Color(1.0, 0.85, 0.0), 0.1)
			tw.tween_property(slot.carta_actual, "modulate", Color.WHITE, 0.2)

func _ataque_doble_columna(grupo_atacante: String, grupo_victima: String, perdida_vida: int) -> void:
	var columnas= [0, 1, 2, 3, 4]
	columnas.shuffle()
	var atacadas= columnas.slice(0, 2)
	for col in atacadas:
		for slot in get_tree().get_nodes_in_group(grupo_victima):
			if slot.columna == col and slot.carta_actual != null and slot.carta_actual.datos.efecto_tipo !=JugadorData.EfectoJugador.NO_TRUCOS:
				slot.carta_actual.recibir_danio(perdida_vida)
				if !slot.carta_actual.esta_viva():
					var carta= slot.carta_actual
					slot.carta_actual= null
					slot.mostrar_visual()
					carta.queue_free()
				else:
					slot.carta_actual.actualizar_carta()
	for slot in get_tree().get_nodes_in_group(grupo_atacante):
		if slot.carta_actual != null:
			slot.carta_actual.recibir_danio(perdida_vida)
			slot.carta_actual.actualizar_carta()
			break

func _inmunidad_arco(grupo_vida: String) -> void:
	var vida= get_tree().get_first_node_in_group(grupo_vida)
	if vida:
		vida.inmune= true

func _expulsar_baratos(grupo: String, costo_max: int) -> void:
	for slot in get_tree().get_nodes_in_group(grupo):
		if slot.carta_actual != null and slot.carta_actual.datos.estrellas < costo_max and slot.carta_actual.datos.efecto_tipo !=JugadorData.EfectoJugador.NO_TRUCOS:
			var carta= slot.carta_actual
			slot.carta_actual= null
			slot.mostrar_visual()
			var tw= carta.create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
			tw.tween_property(carta, "modulate", Color(1.0, 0.3, 0.3), 0.08)
			tw.tween_property(carta, "position", carta.position + Vector2(0, -120), 0.2)
			tw.parallel().tween_property(carta, "scale", Vector2(0.18, 0.18), 0.2)
			tw.parallel().tween_property(carta, "modulate:a", 0.0, 0.18)
			await tw.finished
			carta.queue_free()

func _buff_ataque_jugador(columna: int, grupo: String, valor: int) -> void:
	var slot= _get_slot(columna, grupo)
	if slot == null or slot.carta_actual == null:
		for s in get_tree().get_nodes_in_group(grupo):
			if s.carta_actual != null:
				slot= s
				break
	if slot == null or slot.carta_actual == null:
		return
	slot.carta_actual.datos.stat_ataque += valor
	slot.carta_actual.actualizar_carta()
	var tw= slot.carta_actual.create_tween()
	tw.tween_property(slot.carta_actual, "modulate", Color(1.0, 0.5, 0.0), 0.1)
	tw.tween_property(slot.carta_actual, "scale", Vector2(0.7, 0.7), 0.1)
	tw.tween_property(slot.carta_actual, "scale", Vector2(0.6, 0.6), 0.1)
	tw.parallel().tween_property(slot.carta_actual, "modulate", Color.WHITE, 0.2)

func _curar_vida(grupo_vida: String, valor: int) -> void:
	var vida= get_tree().get_first_node_in_group(grupo_vida)
	if vida:
		vida.curar(valor)

func _danio_directo_pasante(columna: int, grupo_atacante: String, grupo_vida: String) -> void:
	var slot_atacante= _get_slot(columna, grupo_atacante)
	if slot_atacante == null or slot_atacante.carta_actual == null:
		for s in get_tree().get_nodes_in_group(grupo_atacante):
			if s.carta_actual != null:
				slot_atacante= s
				break
	if slot_atacante == null or slot_atacante.carta_actual == null:
		return
	var danio= slot_atacante.carta_actual.datos.stat_ataque
	var vida= get_tree().get_first_node_in_group(grupo_vida)
	if vida:
		vida.recibir_danio(danio)

func _danio_arco_directo(grupo_vida: String, valor: int) -> void:
	var vida= get_tree().get_first_node_in_group(grupo_vida)
	if vida:
		vida.recibir_danio(valor)

func _reducir_vida_columna(columna: int, valor: int) -> void:
	var slot= _get_slot(columna, "slots_enemigo")
	if slot== null or slot.carta_actual== null:
		for s in get_tree().get_nodes_in_group("slots_enemigo"):
			if s.carta_actual !=null:
				slot =s
				break
	if slot== null or slot.carta_actual== null:
		return
	slot.carta_actual.recibir_danio(valor)
	if !slot.carta_actual.esta_viva():
		var carta= slot.carta_actual
		slot.carta_actual= null
		slot.mostrar_visual()
		carta.queue_free()
	else:
		slot.carta_actual.actualizar_carta()
		var tw= slot.carta_actual.create_tween()
		tw.tween_property(slot.carta_actual, "modulate", Color(1.0, 0.3, 0.3), 0.1)
		tw.tween_property(slot.carta_actual, "modulate", Color.WHITE, 0.2)

func _buff_ataque_all(grupo: String, valor: int) -> void:
	for slot in get_tree().get_nodes_in_group(grupo):
		if slot.carta_actual !=null:
			slot.carta_actual.datos.stat_ataque +=valor
			slot.carta_actual.actualizar_carta()
			var tw= slot.carta_actual.create_tween()
			tw.tween_property(slot.carta_actual, "modulate", Color(1.0, 0.6, 0.0), 0.1)
			tw.tween_property(slot.carta_actual, "modulate", Color.WHITE, 0.2)

func _debuff_ataque_all(grupo: String, valor: int) -> void:
	for slot in get_tree().get_nodes_in_group(grupo):
		if slot.carta_actual !=null:
			slot.carta_actual.datos.stat_ataque =max(0, slot.carta_actual.datos.stat_ataque - valor)
			slot.carta_actual.actualizar_carta()
			var tw= slot.carta_actual.create_tween()
			tw.tween_property(slot.carta_actual, "modulate", Color(0.5, 0.0, 0.5), 0.1)
			tw.tween_property(slot.carta_actual, "modulate", Color.WHITE, 0.2)
