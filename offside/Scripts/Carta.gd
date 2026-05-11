extends Node2D

enum Calidad { BRONCE, PLATA, ORO, CAPITAN }

const COLORES_CALIDAD= {Calidad.BRONCE: Color("#993024"), Calidad.PLATA: Color("#978f87"), Calidad.ORO: Color("#d19700"), Calidad.CAPITAN: Color("#00c2d1")}

var calidad_actual: Calidad= Calidad.BRONCE


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index== MOUSE_BUTTON_LEFT and event.pressed:
			calidad_actual =(calidad_actual+ 1)% Calidad.size()
			aplicar_calidad(calidad_actual)

func aplicar_calidad(calidad: Calidad):
	var stylebox= $Base.get_theme_stylebox("panel").duplicate()
	stylebox.border_color= COLORES_CALIDAD[calidad]
	$Base.add_theme_stylebox_override("panel", stylebox)
	$Base/Divisor.color= COLORES_CALIDAD[calidad]
