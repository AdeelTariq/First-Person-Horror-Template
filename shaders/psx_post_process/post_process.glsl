#[compute]
#version 450

#define MAXCOLORS 256

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(rgba16f, binding = 0, set = 0) uniform image2D screen_tex;

layout(push_constant, std430) uniform Params {
	float size_x;
	float size_y;
	float colors;           // Number of colors, should be in range [1, MAXCOLORS]
        float dither_size;      // Dithering size, should be in range [1, 8]
	bool enabled;         // Whether the effect is enabled
        bool dithering;       // Whether dithering is enabled
        vec2 pad;
} p;

vec4 toLinear(vec4 color) {
    return vec4(pow(color.rgb, vec3(2.2)), color.a); // Gamma correction to linear
}

vec4 toSRGB(vec4 color) {
    return vec4(pow(color.rgb, vec3(1.0 / 2.2)), color.a); // Linear to gamma correction
}


float dithering_pattern(ivec2 fragcoord) {
    const float pattern[16] = float[16](
        0.00, 0.50, 0.10, 0.65, 
        0.75, 0.25, 0.90, 0.35, 
        0.20, 0.70, 0.05, 0.50, 
        0.95, 0.40, 0.80, 0.30
    );

    int x = fragcoord.x % 4;
    int y = fragcoord.y % 4;

    return pattern[y * 4 + x];
}

float reduce_color(float raw, float dither, float depth) {
    float div = 1.0 / depth;
    float val = 0.0;
    int i = 0;

    while (i <= MAXCOLORS) {
        if (raw > div * float(i + 1)) {
            i = i + 1;
            continue;
        }

        if ((raw * depth - float(i)) <= dither * 0.999) {
            val = div * float(i);
        } else {
            val = div * float(i + 1);
        }
        return val;

        i = i + 1;
    }

    return val;
}

void main() {
	ivec2 screen_uv = ivec2(gl_GlobalInvocationID.xy);
	ivec2 uv = ivec2(gl_GlobalInvocationID.xy / p.dither_size);
	
	if (screen_uv.x >= p.size_x || screen_uv.y >= p.size_y) return;
	
	vec4 color = toSRGB(imageLoad(screen_tex, screen_uv));

	if (p.enabled) {
		float dithering_value = 1.0;
		if (p.dithering) {
			dithering_value = dithering_pattern(uv);
		}

		float adjusted_dither = (dithering_value - 0.5) * dithering_value + 0.5;

		color.r = reduce_color(color.r, adjusted_dither, p.colors - 1);
		color.g = reduce_color(color.g, adjusted_dither, p.colors - 1);
		color.b = reduce_color(color.b, adjusted_dither, p.colors - 1);
		imageStore(screen_tex, ivec2(gl_GlobalInvocationID.xy), toLinear(color));
	} else {
		imageStore(screen_tex, ivec2(gl_GlobalInvocationID.xy), toLinear(color));
	}
}
