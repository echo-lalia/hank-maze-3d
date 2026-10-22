shader_type spatial;
render_mode blend_add;
render_mode world_vertex_coords;


uniform sampler3D noise_texture;


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
	ALBEDO = vec3(0.9, 1, 0.3);
	ALPHA = texture(noise_texture, vec3(COLOR.r * 1.777 * 0.2, COLOR.g * 0.2 + TIME * 0.01, TIME * 0.1)).r;
	//ALPHA = sin(TIME + (VERTEX.y + VERTEX.x)*10.0 - (TIME * VERTEX.z)*0.4);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
