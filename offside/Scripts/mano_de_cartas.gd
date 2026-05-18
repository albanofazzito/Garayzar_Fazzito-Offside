extends Node2D

var cartas: Array = []
var cartas_max: int = 7


@export var angulo: float = 30.0
@export var spaciado: float = 120.0

func agregar(Carta : PackedScene) -> void:
	var carti = Car   ta.instantiate()
	add_child(carti)
	cartas.append(carti)
	orden()

func sacar(Carta) -> void:
	cartas.erase(Carta)
	Carta.queue_free()
	orden()

func orden() -> void:
	var count = cartas.size()
	for i in count:
		var Carta = cartas[i]
		var offset = (i - (count - 1) / 2.0)
		Carta.position.x = offset * spaciado
		Carta.rotation = deg_to_rad(offset * angulo / count)
