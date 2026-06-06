class_name BatallaManager
extends Node

signal batalla_terminada

@export var vida_enemigo: VidaBase
@export var vida_jugador: VidaBase

var sfx_hit: AudioStreamPlayer
var hits := []
var silbato_sprite: Sprite2D

func _ready() -> void:
	sfx_hit =AudioStreamPlayer.new()
	sfx_hit.volume_db= -20.0
	add_child(sfx_hit)
	hits = [
		load("res://Audio/hitSound1.mp3"),
		load("res://Audio/hitSound2.mp3"),
		load("res://Audio/hitSound3.mp3"),
		load("res://Audio/hitSound4.mp3")
	]
	silbato_sprite =Sprite2D.new()
	silbato_sprite.texture= load("res://Sprites/Iconos/Silbato.png")
	silbato_sprite.scale= Vector2(0.55, 0.55)
	silbato_sprite.z_index= 10
	silbato_sprite.visible= false
	get_tree().current_scene.add_child(silbato_sprite)

func _play_hit() -> void:
	sfx_hit.stream= hits[randi() % hits.size()]
	sfx_hit.play()

func iniciar_batalla() -> void:
	_inicializar_cartas()
	_aplicar_efectos_turno()
	_aplicar_kante()
	var vida_j_antes =vida_jugador.vida_actual if vida_jugador else 0
	var vida_e_antes =vida_enemigo.vida_actual if vida_enemigo else 0
	await get_tree().create_timer(0.4).timeout
	for col in range(5):
		await _resolver_columna(col)
	_check_rage(vida_j_antes, vida_e_antes)
	_aplicar_efectos_post_combate()
	await _limpiar_muertos_global()
	_resetear_inmunidad()
	batalla_terminada.emit()

func _resetear_inmunidad() -> void:
	if vida_jugador:
		vida_jugador.inmune = false
	if vida_enemigo:
		vida_enemigo.inmune = false

func _aplicar_kante() -> void:
	for grupo in ["slots", "slots_enemigo"]:
		var grupo_rival= "slots_enemigo" if grupo == "slots" else "slots"
		for slot in get_tree().get_nodes_in_group(grupo):
			if slot.carta_actual and slot.carta_actual.datos.efecto_tipo ==JugadorData.EfectoJugador.MOVER_BLOQUEO:
				if slot.carta_actual.kante_usado:
					continue
				var slot_rival_vacio= null
				for sr in get_tree().get_nodes_in_group(grupo_rival):
					if sr.carta_actual != null:
						var mi_slot_col= _get_slot(sr.columna, grupo)
						if mi_slot_col and mi_slot_col.carta_actual == null:
							if sr.carta_actual.datos.stat_ataque < slot.carta_actual.vida_actual:
								slot_rival_vacio= mi_slot_col
								break
				if slot_rival_vacio:
					var carta= slot.carta_actual
					slot.carta_actual= null
					slot_rival_vacio.carta_actual= carta
					carta.kante_usado= true
					var destino= carta.get_parent().to_local(slot_rival_vacio.get_global_rect().get_center())
					carta.posicion_original= destino
					carta.animar(destino, 0.0)

func _inicializar_cartas() -> void:
	for slot in get_tree().get_nodes_in_group("slots"):
		if slot.carta_actual:
			slot.carta_actual.inicializar_combate()
	for slot in get_tree().get_nodes_in_group("slots_enemigo"):
		if slot.carta_actual:
			slot.carta_actual.inicializar_combate()

func _aplicar_efectos_turno() -> void:
	for slot in get_tree().get_nodes_in_group("slots"):
		if slot.carta_actual:
			slot.carta_actual.aplicar_efecto_turno()
	for slot in get_tree().get_nodes_in_group("slots_enemigo"):
		if slot.carta_actual:
			slot.carta_actual.aplicar_efecto_turno()

func _check_rage(vida_j_antes: int, vida_e_antes: int) -> void:
	if vida_jugador and vida_jugador.vida_actual <vida_j_antes:
		for slot in get_tree().get_nodes_in_group("slots"):
			if slot.carta_actual:
				slot.carta_actual.activar_rage(vida_jugador.vida_actual)
	if vida_enemigo and vida_enemigo.vida_actual <vida_e_antes:
		for slot in get_tree().get_nodes_in_group("slots_enemigo"):
			if slot.carta_actual:
				slot.carta_actual.activar_rage(vida_enemigo.vida_actual)

func _resolver_columna(col: int) -> void:
	var slot_j =_get_slot(col, "slots")
	var slot_e =_get_slot(col, "slots_enemigo")
	var carta_j =slot_j.carta_actual if slot_j else null
	var carta_e =slot_e.carta_actual if slot_e else null

	if carta_j ==null and carta_e ==null:
		return

	var centro_j= slot_j.get_global_rect().get_center() if slot_j else Vector2.ZERO
	var centro_e= slot_e.get_global_rect().get_center() if slot_e else Vector2.ZERO
	silbato_sprite.position= (centro_j + centro_e) / 2.0
	silbato_sprite.visible= true
	var tw_silb= silbato_sprite.create_tween()
	tw_silb.tween_property(silbato_sprite, "scale", Vector2(0.15, 0.15), 0.1).from(Vector2(0.0, 0.0)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	if carta_j and carta_e:
		if carta_j.datos.stat_velocidad >= carta_e.datos.stat_velocidad:
			await carta_j.animar_ataque(carta_e)
			_play_hit()
			if !carta_e.puede_esquivar():
				carta_e.recibir_danio(carta_j.datos.stat_ataque)
			await _aplicar_splash_col(col, "slots")
			await get_tree().create_timer(0.25).timeout
			await carta_e.animar_ataque(carta_j)
			_play_hit()
			if !carta_j.puede_esquivar():
				carta_j.recibir_danio(carta_e.datos.stat_ataque)
			await _aplicar_splash_col(col, "slots_enemigo")
			await get_tree().create_timer(0.25).timeout
		else:
			await carta_e.animar_ataque(carta_j)
			_play_hit()
			if !carta_j.puede_esquivar():
				carta_j.recibir_danio(carta_e.datos.stat_ataque)
			await _aplicar_splash_col(col, "slots_enemigo")
			await get_tree().create_timer(0.25).timeout
			await carta_j.animar_ataque(carta_e)
			_play_hit()
			if !carta_e.puede_esquivar():
				carta_e.recibir_danio(carta_j.datos.stat_ataque)
			await _aplicar_splash_col(col, "slots")
			await get_tree().create_timer(0.25).timeout
	elif carta_j and !carta_e:
		if vida_enemigo:
			await carta_j.animar_ataque_base()
			_play_hit()
			vida_enemigo.recibir_danio(carta_j.datos.stat_ataque)
			await _aplicar_splash_col(col, "slots")
			await get_tree().create_timer(0.25).timeout
	elif carta_e and !carta_j:
		if vida_jugador:
			await carta_e.animar_ataque_base()
			_play_hit()
			vida_jugador.recibir_danio(carta_e.datos.stat_ataque)
			await _aplicar_splash_col(col, "slots_enemigo")
			await get_tree().create_timer(0.25).timeout

	await get_tree().create_timer(0.35).timeout
	silbato_sprite.visible= false
	await _limpiar_muertos(slot_j, slot_e)

func _limpiar_muertos(slot_j, slot_e) -> void:
	if slot_j and slot_j.carta_actual and !slot_j.carta_actual.esta_viva():
		await _eliminar_carta(slot_j)
	if slot_e and slot_e.carta_actual and !slot_e.carta_actual.esta_viva():
		await _eliminar_carta(slot_e)

func _limpiar_muertos_global() -> void:
	for grupo in ["slots", "slots_enemigo"]:
		for slot in get_tree().get_nodes_in_group(grupo):
			if slot.carta_actual and !slot.carta_actual.esta_viva():
				await _eliminar_carta(slot)

func _aplicar_efectos_post_combate() -> void:
	for grupo in ["slots", "slots_enemigo"]:
		for slot in get_tree().get_nodes_in_group(grupo):
			if slot.carta_actual:
				slot.carta_actual.aplicar_efecto_post_combate()

func _eliminar_carta(slot) -> void:
	var carta =slot.carta_actual
	slot.carta_actual =null
	slot.mostrar_visual()
	if carta.tween_color:
		carta.tween_color.kill()
	var tw =carta.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_property(carta, "scale", Vector2(0.72, 0.48), 0.08)
	tw.parallel().tween_property(carta, "modulate", Color(0.5, 0.5, 0.5), 0.08)
	tw.tween_property(carta, "scale", Vector2(0.0, 0.0), 0.25)
	tw.parallel().tween_property(carta, "rotation", deg_to_rad(20.0), 0.25)
	tw.parallel().tween_property(carta, "modulate:a", 0.0, 0.2)
	await tw.finished
	carta.queue_free()

func _get_slot(col: int, grupo: String):
	for slot in get_tree().get_nodes_in_group(grupo):
		if slot.columna ==col:
			return slot
	return null

func _aplicar_splash_col(col_actual: int, grupo_atacante: String) -> void:
	var slot_atk= _get_slot(col_actual, grupo_atacante)
	if slot_atk ==null or slot_atk.carta_actual ==null:
		return
	var carta= slot_atk.carta_actual
	if carta.datos.efecto_tipo !=JugadorData.EfectoJugador.DANIO_TODAS_LINEAS:
		return
	var grupo_victima= "slots" if grupo_atacante == "slots_enemigo" else "slots_enemigo"
	var muertos: Array =[]
	for slot in get_tree().get_nodes_in_group(grupo_victima):
		if slot.columna != col_actual and slot.carta_actual != null:
			slot.carta_actual.recibir_danio(carta.datos.efecto_valor)
			if !slot.carta_actual.esta_viva():
				muertos.append(slot)
	for slot in muertos:
		await _eliminar_carta(slot)
