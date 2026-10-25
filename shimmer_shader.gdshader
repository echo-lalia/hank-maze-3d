shader_type spatial;
render_mode blend_add;
render_mode world_vertex_coords;
render_mode unshaded;


uniform vec4 shimmer_color: source_color;
uniform sampler3D noise_texture;
global uniform sampler2D beyer_matrix: filter_nearest;
global uniform float viewport_width_beyer;
global uniform float viewport_height_beyer;

void vertex() {
	// Called for every vertex the material is visible on.
	
	VERTEX += (
		//NORMAL * 0.005
		+ ((MAIN_CAM_INV_VIEW_MATRIX * vec4(0.0, 0.0, 1.0, 0.0)).xyz) * 0.005
	);
	COLOR.rgb = VERTEX;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = shimmer_color.rgb;
	float beyer_threshold = texture(beyer_matrix, SCREEN_UV * vec2(viewport_width_beyer, viewport_height_beyer)).r;
	float noise_sample = texture(noise_texture, vec3(COLOR.r * 1.777 * 0.2, COLOR.g * 0.2 + TIME * 0.01, TIME * 0.1)).r;
	noise_sample = smoothstep(noise_sample, 0, 0.3);
	ALPHA = (noise_sample > beyer_threshold) ? shimmer_color.a : 0.0;
	//if (noise_sample > beyer_threshold) {
	//	
	//}
	//ALPHA = sin(TIME + (VERTEX.y + VERTEX.x)*10.0 - (TIME * VERTEX.z)*0.4);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
