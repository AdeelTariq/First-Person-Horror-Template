#[compute]
#version 450

layout(local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout(rgba16f, binding = 0, set = 0) uniform image2D screen_tex;

layout(push_constant, std430) uniform Params {
	float size_x;
	float size_y;
	float factor;
} p;

vec4 toLinear(vec4 color) {
    return vec4(pow(color.rgb, vec3(2.2)), color.a); // Gamma correction to linear
}

vec4 toSRGB(vec4 color) {
    return vec4(pow(color.rgb, vec3(1.0 / 2.2)), color.a); // Linear to gamma correction
}

void main() {
	ivec2 screen_uv = ivec2(gl_GlobalInvocationID.xy);
	if (screen_uv.x >= p.size_x || screen_uv.y >= p.size_y) return;

	// Determine the size of each block in the input image
	ivec2 blockSize = ivec2(p.factor);

	// Calculate the top-left corner of the block in the input image
	ivec2 inputStart = screen_uv * blockSize;

	// Accumulate color values
	vec4 colorSum = vec4(0.0);
	int pixelCount = 0;

	// Iterate over the block of pixels
	for (int y = 0; y < blockSize.y; y++) {
	for (int x = 0; x < blockSize.x; x++) {
	    ivec2 inputCoord = inputStart + ivec2(x, y);
	    colorSum += imageLoad(screen_tex, inputCoord);
	    pixelCount++;
	}
	}

	// Calculate the average color
	vec4 avgColor = colorSum / float(pixelCount);


	// Write the average color to the output image
	//imageStore(screen_tex, screen_uv, avgColor);
	
	for (int y = 0; y < blockSize.y; y++) {
	for (int x = 0; x < blockSize.x; x++) {
	    ivec2 inputCoord = inputStart + ivec2(x, y);
	    imageStore(screen_tex, inputCoord, avgColor);
	}
	}
}
