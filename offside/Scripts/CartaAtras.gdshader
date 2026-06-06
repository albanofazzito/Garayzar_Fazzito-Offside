shader_type canvas_item;

uniform float radio: hint_range(0.0, 0.5) = 0.1;
uniform float escala_vertical: hint_range(0.1, 1.0) = 0.875;
uniform float angulo_borde: hint_range(-1.0, 1.0) = 0.0;

void fragment() {
	vec2 uv = UV - 0.5;
	uv.x -= uv.y * angulo_borde;

	vec2 uv_recorte = vec2(uv.x, uv.y / escala_vertical);
	vec2 size = vec2(0.5 - radio);
	vec2 d = abs(uv_recorte) - size;
	float dist = length(max(d, 0.0)) - radio;

	if (dist > 0.0) {
		discard;
	}
	COLOR = texture(TEXTURE, UV);
}