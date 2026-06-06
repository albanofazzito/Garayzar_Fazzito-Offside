shader_type canvas_item;

uniform float top_left     : hint_range(0.0, 0.5) = 0.0;
uniform float top_right    : hint_range(0.0, 0.5) = 0.0;
uniform float bottom_left  : hint_range(0.0, 0.5) = 0.0;
uniform float bottom_right : hint_range(0.0, 0.5) = 0.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    float aspect= TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x;

    float rx =top_left;
    float ry= top_left * aspect;
    if (rx > 0.0 && UV.x < rx && UV.y < ry)
        if (length((UV - vec2(rx, ry)) / vec2(rx, ry)) > 1.0) color.a =0.0;

    rx= top_right;
    ry =top_right * aspect;
    if (rx > 0.0 && UV.x > 1.0 - rx && UV.y < ry)
        if (length((UV - vec2(1.0 - rx, ry)) / vec2(rx, ry)) > 1.0) color.a= 0.0;

    rx =bottom_left;
    ry= bottom_left * aspect;
    if (rx > 0.0 && UV.x < rx && UV.y > 1.0 - ry)
        if (length((UV - vec2(rx, 1.0 - ry)) / vec2(rx, ry)) > 1.0) color.a =0.0;

    rx= bottom_right;
    ry =bottom_right * aspect;
    if (rx > 0.0 && UV.x > 1.0 - rx && UV.y > 1.0 - ry)
        if (length((UV - vec2(1.0 - rx, 1.0 - ry)) / vec2(rx, ry)) > 1.0) color.a= 0.0;

    COLOR = color;
}