class_name TrucoData
extends JugadorData	

enum TipoEfecto {
	EXPULSAR_CARTA_ENEMIGA,
	EXPULSAR_CARTA_PROPIA,
	BUFF_ATAQUE_COLUMNA,
	BUFF_VIDA_COLUMNA,
	DANIO_DIRECTO,
	ROBAR_CARTAS,
}

@export var tipo_efecto: TipoEfecto =TipoEfecto.EXPULSAR_CARTA_ENEMIGA
@export var valor: int =0
