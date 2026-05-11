shader_type canvas_item;

uniform float radius : hint_range(0.0, 300.0) = 20.0;

void fragment() {
    vec2 size = 1.0 / TEXTURE_PIXEL_SIZE;
    vec2 px = UV * size;
    vec4 color = texture(TEXTURE, UV);

    if (px.x < radius && px.y < radius) {
        if (length(px - vec2(radius, radius)) > radius) {
            color.a = 0.0;
        }
    }
    if (px.x > size.x - radius && px.y < radius) {
        if (length(px - vec2(size.x - radius, radius)) > radius) {
            color.a = 0.0;
        }
    }

    COLOR = color;
}