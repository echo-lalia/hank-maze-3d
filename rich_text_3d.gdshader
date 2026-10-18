shader_type spatial;


uniform sampler2D viewport_texture;



float rand(vec2 co){
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
	// Called for every vertex the material is visible on.
	float time_step = floor(TIME*3.99);
	VERTEX += vec3(
		fract(rand(vec2(time_step, float(VERTEX_ID))))*0.2 - 0.1,
		fract(rand(vec2(float(VERTEX_ID), time_step)))*0.2 - 0.1,
		0
	);
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 sample = texture(viewport_texture, UV);
	ALBEDO = sample.rgb;
	ALPHA = sample.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
