shader_type canvas_item;

uniform float gamma: hint_range(0.0, 2.0, 0.05) = 1.0;

void fragment() {
    vec4 color = COLOR;
    color.rgb = pow(color.rgb, vec3(1.0 / gamma));
    COLOR = color;
}