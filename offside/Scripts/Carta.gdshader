shader_type canvas_item;

uniform float radius : hint_range(0.0, 0.5) = 0.08;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    float aspect =TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x;
    float rx= radius;
    float ry =radius * aspect;

    if (UV.x < rx && UV.y < ry) {
        vec2 d =(UV - vec2(rx, ry)) / vec2(rx, ry);
        if (length(d) > 1.0) color.a= 0.0;
    }
    if (UV.x > 1.0 - rx && UV.y < ry) {
        vec2 d= (UV - vec2(1.0 - rx, ry)) / vec2(rx, ry);
        if (length(d) > 1.0) color.a =0.0;
    }

    COLOR = color;
}