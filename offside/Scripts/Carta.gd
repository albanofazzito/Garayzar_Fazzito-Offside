extends Panel


const COLORES_CALIDAD= {JugadorData.Calidad.BRONCE: Color("#993024"), 
JugadorData.Calidad.PLATA: Color("#978f87"), 
JugadorData.Calidad.ORO: Color("#d19700"), 
JugadorData.Calidad.CAPITAN: Color("#00c2d1")}



@export var datos: JugadorData:
	set(value):
		datos= value
		if is_node_ready():
			actualizar_carta()




func actualizar_carta():
	$Jugador.texture = datos.foto
	$InfoJugador.text = datos.info
	$InfoJugadorBorde.text= datos.info
	$RecipienteEstrellas/Coste.text= datos.estrellas
	$Stats/CajaAtaque/NumeroAtaque.text= datos.stat_ataque
	$Stats/CajaVelocidad/NumeroVelocidad.text= datos.stat_velocidad
	$Stats/CajaDefensa/NumeroDefensa.text= datos.stat_vida
	aplicarCalidad(datos.calidad)
	
func aplicarCalidad(calidad: JugadorData.Calidad):
	var color = COLORES_CALIDAD[calidad]
	var estilo = get_theme_stylebox("panel").duplicate()
	estilo.border_color = color
	add_theme_stylebox_override("panel", estilo)
