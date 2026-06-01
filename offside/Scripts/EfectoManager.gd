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

func _expulsar_carta(columna: int, grupo: String, mano_devolver: Mano) -> void:
	var slot =_get_slot(columna, grupo)
	if slot ==null or slot.carta_actual ==null:
		for s in get_tree().get_nodes_in_group(grupo):
			if s.carta_actual !=null:
				slot =s
				break
	if slot ==null or slot.carta_actual ==null:
		return
	var carta =slot.carta_actual
	slot.carta_actual =null
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
