extends Node2D

var cartas : Array = []
var cartas_max: int = 7

@export var angulo: float = 30.0
@export var spaciado: float = 120.0

var escenaCarta= load("res://Escenas/Carta.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and cartas.size()<cartas_max   :
		if event.keycode == KEY_SPACE and event.pressed:
			agregar(escenaCarta)

func agregar(escenaCarta) -> void:
	var carti = escenaCarta.instantiate()
	add_child(carti)
	cartas.append(carti)
	orden()

func sacar(escenaCarta) -> void:
	cartas.erase(escenaCarta)
	escenaCarta.queue_free()
	orden()        

func orden() -> void:
	var count = cartas.size()
	for i in count:
		var Carta = cartas[i]
		var offset = (i - (count - 1) / 2.0)
		Carta.position.x = offset * spaciado
