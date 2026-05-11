shader_type canvas_item;

uniform float top_left     : hint_range(0.0, 300.0) = 20.0;
uniform float top_right    : hint_range(0.0, 300.0) = 20.0;
uniform float bottom_left  : hint_range(0.0, 300.0) = 20.0;
uniform float bottom_right : hint_range(0.0, 300.0) = 20.0;

void fragment() {
    vec2 size = 1.0 / TEXTURE_PIXEL_SIZE;
    vec2 px = UV * size;
    vec4 color = texture(TEXTURE, UV);

    if (px.x < top_left && px.y < top_left)
        if (length(px - vec2(top_left)) > top_left) color.a = 0.0;

    if (px.x > size.x - top_right && px.y < top_right)
        if (length(px - vec2(size.x - top_right, top_right)) > top_right) color.a = 0.0;

    if (px.x < bottom_left && px.y > size.y - bottom_left)
        if (length(px - vec2(bottom_left, size.y - bottom_left)) > bottom_left) color.a = 0.0;

    if (px.x > size.x - bottom_right && px.y > size.y - bottom_right)
        if (length(px - vec2(size.x - bottom_right, size.y - bottom_right)) > bottom_right) color.a = 0.0;

    COLOR = color;
}