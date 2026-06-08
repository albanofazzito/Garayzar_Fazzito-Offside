class_name JugadorData
extends Resource
enum Calidad { BRONCE, PLATA, ORO, CAPITAN }
enum Posicion {ARQUERO, DEFENSOR, MEDIOCAMPISTA, DELANTERO,TODO}
enum Pais { ARGENTINA, BRASIL, FRANCIA, INGLATERRA, ALEMANIA, HOLANDA, ESPANA, PORTUGAL}
enum EfectoJugador {NINGUNO, MULTIPOSICION, BUFF_ATAQUE_POR_TURNO, ESQUIVAR_CADA_2, RAGE_AL_GOL, SINERGIA_HERMANOS, COMPARTIR_DANIO, BUFF_VIDA_COMPANERO, DANIO_TODAS_LINEAS, MATAR_ALEATORIO, MOVER_BLOQUEO, DANIO_ARCO_TURNO, DANIO_LINEA_DERECHA, DANIO_LINEA_IZQUIERDA, NO_TRUCOS, GOLEADOR, JOGADINHA_DO_PAQUETA, ADIOS_DIOGO, TE_QUIERO_AMIGO, MEJOR_REPRESENTANTE, BAGGIO, BUFF_VIDA_POR_TURNO}
@export var pais: Pais = Pais.ARGENTINA
@export var posicion: Posicion= Posicion.ARQUERO
@export var efecto_tipo: EfectoJugador= EfectoJugador.NINGUNO
@export var efecto_valor: int= 0
@export var info: String= ""
@export var foto: Texture2D
@export var bandera: Texture2D
@export var efecto: String= ""
@export var stat_ataque: int= 0
@export var stat_velocidad: int= 0
@export var stat_vida: int= 0
@export var estrellas: int= 0
@export var calidad: Calidad= Calidad.BRONCE
