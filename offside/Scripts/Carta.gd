class_name Carta
extends Node2D


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
	aplicarCalidad(datos.calidad)

func aplicarCalidad(calidad: JugadorData.Calidad):
	var color = COLORES_CALIDAD[calidad]
	var Panel= $Base
	var estilo = Panel.get_theme_stylebox("panel").duplicate()
	estilo.border_color = color
	Panel.add_theme_stylebox_override("panel", estilo)
	$Base/Divisor.color= color
