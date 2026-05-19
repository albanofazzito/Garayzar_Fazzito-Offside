class_name JugadorData
extends Resource
enum Calidad { BRONCE, PLATA, ORO, CAPITAN }
enum Posicion {ARQUERO, DEFENSOR, MEDIOCAMPISTA, DELANTERO}
enum Pais { ARGENTINA, BRASIL, FRANCIA, INGLATERRA, ALEMANIA, HOLANDA, ESPAÑA, PORTUGAL}
@export var pais: Pais = Pais.ARGENTINA
@export var posicion: Posicion= Posicion.ARQUERO
@export var info: String= ""
@export var foto: Texture2D
@export var bandera: Texture2D
@export var efecto: String= ""
@export var stat_ataque: int= 0
@export var stat_velocidad: int= 0
@export var stat_vida: int= 0
@export var estrellas: int= 0
@export var calidad: Calidad= Calidad.BRONCE
