extends Control

var dts := [
	{
		"nombre": "Scaloni",
		"pais": "Argentina",
		"color": Color(0.45, 0.75, 1.0),
		"ataque": 5,
		"defensa": 4,
		"velocidad": 3,
		"trucos": 2,
		"enum_pais": JugadorData.Pais.ARGENTINA,
		"foto_ruta": "res://Sprites/Paises/Argentina/DT/scaloni.png"
	},
	{
		"nombre": "Ancelotti",
		"pais": "Brasil",
		"color": Color(1.0, 0.85, 0.0),
		"ataque": 3,
		"defensa": 3,
		"velocidad": 4,
		"trucos": 5,
		"enum_pais": JugadorData.Pais.BRASIL,
		"foto_ruta": "res://Sprites/Paises/Brasil/DT/ancelotti.png"
	},
	{
		"nombre": "Deschamps",
		"pais": "Francia",
		"color": Color(0.2, 0.3, 0.8),
		"ataque": 4,
		"defensa": 5,
		"velocidad": 5,
		"trucos": 3,
		"enum_pais": JugadorData.Pais.FRANCIA,
		"foto_ruta": "res://Sprites/Paises/Francia/DT/dechamps.png"
	},
	{
		"nombre": "Martinez",
		"pais": "Portugal",
		"color": Color(0.0, 0.5, 0.2),
		"ataque": 4,
		"defensa": 3,
		"velocidad": 4,
		"trucos": 2,
		"enum_pais": JugadorData.Pais.PORTUGAL,
		"foto_ruta": "res://Sprites/Paises/Portugal/DT/martinez.png"
	},
]

var indice_actual: int =0
var containers: Array= []
var tween_activo: Tween

@onready var galeria: Control= $Galeria
@onready var flecha_izq: Button= $FlechaIzq
@onready var flecha_der: Button= $FlechaDer
@onready var boton_elegir: Button= $BotonElegir

func _ready() -> void:
	Global.iniciar_musica_menu()
	flecha_izq.pressed.connect(_ir_izquierda)
	flecha_der.pressed.connect(_ir_derecha)
	boton_elegir.pressed.connect(_elegir_dt)
	_crear_containers()
	_actualizar_galeria()

func _crear_containers() -> void:
	for dt in dts:
		var cont= _crear_container_dt(dt)
		galeria.add_child(cont)
		containers.append(cont)

func _crear_container_dt(dt: Dictionary) -> PanelContainer:
	var panel= PanelContainer.new()
	var style= StyleBoxFlat.new()
	style.bg_color= Color(0.12, 0.12, 0.14)
	style.border_color= Color(0.85, 0.85, 0.85)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(16)
	panel.add_theme_stylebox_override("panel", style)
	panel.custom_minimum_size= Vector2(240, 360)
	panel.pivot_offset= Vector2(120, 180)

	var vbox= VBoxContainer.new()
	vbox.alignment= BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 6)
	panel.add_child(vbox)

	var hex_color= "#" + dt["color"].to_html(false)
	var nombre_label= RichTextLabel.new()
	nombre_label.bbcode_enabled= true
	nombre_label.text= "[center][b][color=" + hex_color + "][font_size=24]" + dt["nombre"].to_upper() + "[/font_size][/color][/b][/center]"
	nombre_label.fit_content= true
	nombre_label.custom_minimum_size= Vector2(200, 30)
	nombre_label.scroll_active= false
	vbox.add_child(nombre_label)

	var pais_label= RichTextLabel.new()
	pais_label.bbcode_enabled= true
	pais_label.text= "[center][i][color=#999999][font_size=13]" + dt["pais"] + "[/font_size][/color][/i][/center]"
	pais_label.fit_content= true
	pais_label.custom_minimum_size= Vector2(200, 20)
	pais_label.scroll_active= false
	vbox.add_child(pais_label)

	var foto= TextureRect.new()
	foto.custom_minimum_size= Vector2(130, 130)
	foto.stretch_mode= TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	foto.expand_mode= TextureRect.EXPAND_IGNORE_SIZE
	if ResourceLoader.exists(dt["foto_ruta"]):
		foto.texture= load(dt["foto_ruta"])
	vbox.add_child(foto)

	var separador= HSeparator.new()
	separador.add_theme_constant_override("separation", 8)
	vbox.add_child(separador)

	var stats_cont= VBoxContainer.new()
	stats_cont.add_theme_constant_override("separation", 4)
	_agregar_stat_bar(stats_cont, "ATQ", dt["ataque"], dt["color"])
	_agregar_stat_bar(stats_cont, "DEF", dt["defensa"], dt["color"])
	_agregar_stat_bar(stats_cont, "VEL", dt["velocidad"], dt["color"])
	_agregar_stat_bar(stats_cont, "TRC", dt["trucos"], dt["color"])
	vbox.add_child(stats_cont)

	return panel

func _agregar_stat_bar(parent: Control, stat_name: String, valor: int, color: Color) -> void:
	var hbox= HBoxContainer.new()
	hbox.custom_minimum_size= Vector2(200, 18)
	hbox.add_theme_constant_override("separation", 6)

	var hex= "#" + color.to_html(false)
	var lbl= RichTextLabel.new()
	lbl.bbcode_enabled= true
	lbl.text= "[b][font_size=11][color=#cccccc]" + stat_name + "[/color][/font_size][/b]"
	lbl.fit_content= true
	lbl.custom_minimum_size= Vector2(40, 14)
	lbl.scroll_active= false
	hbox.add_child(lbl)

	var bar_container= HBoxContainer.new()
	bar_container.custom_minimum_size= Vector2(140, 14)
	bar_container.add_theme_constant_override("separation", 3)
	for i in 5:
		var seg= PanelContainer.new()
		seg.custom_minimum_size= Vector2(22, 12)
		var seg_style= StyleBoxFlat.new()
		seg_style.set_corner_radius_all(2)
		seg_style.border_color= Color(0.7, 0.7, 0.7)
		seg_style.set_border_width_all(1)
		if i < valor:
			seg_style.bg_color= color
		else:
			seg_style.bg_color= Color(0.25, 0.25, 0.28)
		seg.add_theme_stylebox_override("panel", seg_style)
		bar_container.add_child(seg)
	hbox.add_child(bar_container)
	parent.add_child(hbox)

func _actualizar_galeria() -> void:
	if tween_activo and tween_activo.is_running():
		tween_activo.kill()
	tween_activo= create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	var centro= galeria.size / 2.0
	for i in containers.size():
		var cont= containers[i]
		var diff= i - indice_actual
		var target_x= centro.x + diff * 280 - 120
		var target_y= centro.y - 180
		var target_scale: Vector2
		var target_alpha: float

		if diff == 0:
			target_scale= Vector2(1.15, 1.15)
			target_alpha= 1.0
		elif abs(diff) == 1:
			target_scale= Vector2(0.85, 0.85)
			target_alpha= 0.5
		else:
			target_scale= Vector2(0.6, 0.6)
			target_alpha= 0.0

		tween_activo.tween_property(cont, "position", Vector2(target_x, target_y), 0.3)
		tween_activo.tween_property(cont, "scale", target_scale, 0.3)
		tween_activo.tween_property(cont, "modulate:a", target_alpha, 0.3)

func _ir_izquierda() -> void:
	indice_actual= (indice_actual - 1 + dts.size()) % dts.size()
	_actualizar_galeria()

func _ir_derecha() -> void:
	indice_actual= (indice_actual + 1) % dts.size()
	_actualizar_galeria()

func _elegir_dt() -> void:
	Global.pais_jugador= dts[indice_actual]["enum_pais"]
	Global.escenario_actual= Global.Escenario.TUTORIAL
	Transicion.cambiar_escena("res://Escenas/Nivel.tscn")
