class_name Carta
extends Node2D

var frente_visible: bool = true
var hover: bool = false
var posicion_original: Vector2
var rotacion_original: float
var tween: Tween
var en_mano: bool = true



var COLORES_CALIDAD = {
	JugadorData.Calidad.BRONCE: Color("#993024"), 
	JugadorData.Calidad.PLATA: Color("#978f87"), 
	JugadorData.Calidad.ORO: Color("#d19700"), 
	JugadorData.Calidad.CAPITAN: Color("#00c2d1")
}
var posiciones = ["ARQUERO", "DEFENSOR", "MEDIOCAMPISTA", "DELANTERO"]
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
	$Base/InfoJugadorBorde.text =datos.info
	$Base/Stats/CajaAtaque/NumeroAtaque.text= str(datos.stat_ataque)
	$Base/Stats/CajaVelocidad/NumeroVelocidad.text =str(datos.stat_velocidad)
	$Base/Stats/CajaDefensa/NumeroDefensa.text= str(datos.stat_vida)
	$Base/RecipienteEstrellas/Coste.text =str(datos.estrellas)
	$BaseAtras/Bandera.texture= datos.bandera
	$BaseAtras/CajaEfecto/Efecto.text =datos.efecto
	$Base/PaisJugador.text= paises[datos.pais]
	$Base/PaisJugadorBorde.text =paises[datos.pais]
	$Base/Posicion.text= posiciones[datos.posicion]
	$BaseTruco/Efecto.text= datos.efecto
	$BaseTruco/ImagenTruco.texture =datos.foto
	$BaseTruco/InfoTruco.text=datos.info
	$BaseTruco/InfoTrucoBorde.text=datos.info
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
	if event is InputEventMouseMotion:
		if $Base.get_global_rect().has_point(event.global_position):
			var hay_carta_encima =false
			for carta in get_parent().cartas:
				if carta !=self and carta.z_index > z_index:
					if carta.get_node("Base").get_global_rect().has_point(event.global_position):
						hay_carta_encima =true
						break
			if !hay_carta_encima and !hover:
				hover =true
				posicion_original= position
				rotacion_original =rotation
				position.y -=80.0
				rotation= 0.0
				z_index =10
				animar(Vector2(position.x, position.y - 80.0), 0.0)
		else:
			if hover:
				hover= false
				z_index =0
				animar(posicion_original, rotacion_original)

	if event is InputEventMouseButton:
		if event.button_index ==MOUSE_BUTTON_LEFT and event.pressed:
			if $Base.get_global_rect().has_point(event.global_position):
				var hay_carta_encima =false
				for carta in get_parent().cartas:
					if carta !=self and carta.z_index > z_index:
						if carta.get_node("Base").get_global_rect().has_point(event.global_position):
							hay_carta_encima =true
							break
				if !hay_carta_encima and hover:
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
	rotacion_original =rot
	if !hover:
		position =pos
		rotation =rot
