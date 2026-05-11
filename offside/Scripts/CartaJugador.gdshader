shader_type canvas_item;

uniform vec4 color_inicio : source_color = vec4(0.0, 0.8, 1.0, 1.0);
uniform vec4 color_fin    : source_color = vec4(1.0, 0.0, 0.3, 1.0);

void fragment() {
    vec4 texto = texture(TEXTURE, UV);
    if (texto.a < 0.01) discard;
    vec4 degradado = mix(color_inicio, color_fin, UV.x);
    COLOR = vec4(degradado.rgb, texto.a);
}