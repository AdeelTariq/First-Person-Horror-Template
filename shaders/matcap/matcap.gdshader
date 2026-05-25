shader_type spatial;
render_mode unshaded;

uniform sampler2D texture_albedo : source_color, repeat_disable;
uniform float edge_fix: hint_range(0.0, 0.03, 0.001) = 0.01;

vec2 matcap_uv(vec3 view, vec3 normal) {
	normal = normalize(normal);
    vec3 up = abs(view.y) > 0.999 ? vec3(0.0, 0.0, 1.0) : vec3(0.0, 1.0, 0.0);
    vec3 tangent = normalize(cross(up, view));
    vec3 bitangent = cross(view, tangent);
    vec2 uv = vec2(dot(tangent, normal), -dot(bitangent, normal));
    return uv * (0.5 - edge_fix) + 0.5;
}

void fragment() {
    vec2 uv = matcap_uv(VIEW, NORMAL);
    ALBEDO = texture(texture_albedo, uv).rgb;
}
