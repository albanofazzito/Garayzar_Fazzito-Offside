shader_type canvas_item;

uniform float radio: hint_range(0.0, 0.5) = 0.06;

void fragment() {
	vec2 uv = UV - 0.5;
	vec2 size = vec2(0.5 - radio);
	vec2 d = abs(uv) - size;
	float dist = length(max(d, 0.0)) - radio;
	if (dist > 0.0) {
		discard;
	}
	COLOR = texture(TEXTURE, UV);
}