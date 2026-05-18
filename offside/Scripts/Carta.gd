class_name Carta
extends Node2D

var frente_visible: bool = true
var COLORES_CALIDAD = {
	JugadorData.Calidad.BRONCE: Color("#993024"), 
	JugadorData.Calidad.PLATA: Color("#978f87"), 
	JugadorData.Calidad.ORO: Color("#d19700"), 
	JugadorData.Calidad.CAPITAN: Color("#00c2d1")
}

@export var datos: JugadorData:
	set(value):
		datos = value
		if is_node_ready():
			actualizar_carta()

func actualizar_carta():
	$Base/Jugador.texture = datos.foto
	$Base/InfoJugador.text = datos.info
	$Base/InfoJugadorBorde.text = datos.info
	$Base/Stats/CajaAtaque/NumeroAtaque.text = str(datos.stat_ataque)
	$Base/Stats/CajaVelocidad/NumeroVelocidad.text = str(datos.stat_velocidad)
	$Base/Stats/CajaDefensa/NumeroDefensa.text = str(datos.stat_vida)
	$Base/RecipienteEstrellas/Coste.text = str(datos.estrellas)
	$BaseAtras/Bandera.texture=datos.bandera
	$BaseAtras/CajaEfecto/Efecto.text=datos.efecto
	aplicarCalidad(datos.calidad)

func aplicarCalidad(calidad: JugadorData.Calidad):
	var color = COLORES_CALIDAD[calidad]
	var Panel= $Base
	var Panel2= $BaseAtras
	var estilo = Panel.get_theme_stylebox("panel").duplicate()
	estilo.border_color = color
	Panel.add_theme_stylebox_override("panel", estilo)
	Panel2.add_theme_stylebox_override("panel",estilo)
	$Base/Divisor.color= color

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index== MOUSE_BUTTON_LEFT and event.pressed:
			if $Base.get_global_rect().has_point(event.global_position):
				var hay_carta_encima= false
				for carta in get_parent().cartas:
					if carta!=self and carta.z_index > z_index:
						if carta.get_node("Base").get_global_rect().has_point(event.global_position):
							hay_carta_encima= true
							break
				if !hay_carta_encima:
					voltear()
					get_viewport().set_input_as_handled()

func voltear() -> void:
	frente_visible= !frente_visible
	$Base.visible= frente_visible
	$BaseAtras.visible= !frente_visible
	if !frente_visible:
		z_index= 10  
	else:
		z_index= 0   
