shader_type spatial;
render_mode cull_disabled, unshaded, blend_add;


uniform sampler2DArray texture_albedo : source_color, filter_nearest_mipmap, repeat_enable;
global uniform float vertex_quant;
global uniform sampler2D beyer_matrix: filter_nearest;
global uniform float viewport_width_beyer;
global uniform float viewport_height_beyer;


//vec3 quantize_vert(vec3 vert) {
//	return round(vert * vertex_quant) / vertex_quant;
//}
//
//
//void vertex() {
//	VERTEX = quantize_vert(VERTEX);
//}


void fragment() {
	float beyer_threshold = 1.0 - texture(beyer_matrix, SCREEN_UV * vec2(viewport_width_beyer, viewport_height_beyer)).r;
	vec3 texuv = vec3(UV, COLOR.r * 3.0);
	vec4 tex_sample = texture(texture_albedo, texuv);
	ALBEDO = tex_sample.rgb;
	
	if ((tex_sample.a * COLOR.g) < beyer_threshold) {
		ALPHA = tex_sample.a;
	}
	else {
		ALPHA = 0.0;
	}
	
}

//void light() {
//	float beyer_threshold = texture(beyer_matrix, SCREEN_UV * vec2(viewport_width_beyer, viewport_height_beyer)).r;
//	float diffuse;
//	
//	// https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/spatial_shader.html#light-built-ins
//	if (LIGHT_IS_AREA) {
//		if (LIGHT_AREA_DIFFUSE_MULTIPLIER.r > beyer_threshold) {
//			DIFFUSE_LIGHT += LIGHT_AREA_DIFFUSE_MULTIPLIER * ATTENUATION * LIGHT_COLOR;
//		}
//	}
//	else {
//		diffuse = clamp(dot(LIGHT, NORMAL), 0.0, 1.0);
//		if (diffuse > beyer_threshold) {
//			DIFFUSE_LIGHT += diffuse * LIGHT_COLOR * ATTENUATION;
//		}
//	}
//	
//}
