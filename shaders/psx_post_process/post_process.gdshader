shader_type canvas_item;

render_mode unshaded;

#define MAXCOLORS 256

uniform bool enabled = true;
uniform bool dithering = true;
uniform int colors : hint_range(1, MAXCOLORS) = 12;
uniform int dither_size: hint_range(1, 8) = 1;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear, repeat_disable;

float dithering_pattern(ivec2 fragcoord) {
	const float pattern[] = {
		0.00, 0.50, 0.10, 0.65,
		0.75, 0.25, 0.90, 0.35,
		0.20, 0.70, 0.05, 0.50,
		0.95, 0.40, 0.80, 0.30
	};

	int x = fragcoord.x % 4;
	int y = fragcoord.y % 4;

	return pattern[y * 4 + x];
}

float reduce_color(float raw, float dither, int depth) {
	float div = 1.0 / float(depth);
	float val = 0.0;
	int i = 0;

	while (i <= MAXCOLORS)
	{
		if (raw > div * (float(i + 1))) {
			i = i + 1;
			continue;
		}

		if (raw * float(depth) - float(i) <= dither * 0.999)
		{
			val = div * float(i);
		}
		else
		{
			val = div * float(i + 1);
		}
		return val;

		i = i+1;
	}

	return val;
}

void fragment() {
	vec4 raw = texture(SCREEN_TEXTURE, SCREEN_UV);
	ivec2 uv = ivec2(FRAGCOORD.xy / float(dither_size));

	if (enabled == true){
		float dithering_value = 1.0;
		if (dithering)
		{
			dithering_value = dithering_pattern(uv);
		}

		COLOR.r = reduce_color(raw.r, (dithering_value - 0.5) * dithering_value + 0.5, colors - 1);
		COLOR.g = reduce_color(raw.g, (dithering_value - 0.5) * dithering_value + 0.5, colors - 1);
		COLOR.b = reduce_color(raw.b, (dithering_value - 0.5) * dithering_value + 0.5, colors - 1);

	} else {
		COLOR.rgb = raw.rgb;
	}
}