shader_type spatial;
render_mode diffuse_burley, world_vertex_coords;


const vec3 emmision_color = vec3(1.0, 0.6, 0.4) * 0.3;

uniform sampler2D texture_albedo : source_color, filter_nearest_mipmap, repeat_enable;
global uniform float vertex_quant;
global uniform sampler2D beyer_matrix: filter_nearest;
global uniform float viewport_width_beyer;
global uniform float viewport_height_beyer;


vec3 quantize_vert(vec3 vert) {
	return round(vert * vertex_quant) / vertex_quant;
}


void vertex() {
	VERTEX = quantize_vert(VERTEX);
}


void fragment() {
	ALBEDO = texture(texture_albedo, UV).rgb;
	//EMISSION += emmision_strength * ALBEDO;
	//EMISSION += emmision_color * ALBEDO;
}

void light() {
	float beyer_threshold = texture(beyer_matrix, SCREEN_UV * vec2(viewport_width_beyer, viewport_height_beyer)).r;
	float diffuse;
	
	// https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/spatial_shader.html#light-built-ins
	if (LIGHT_IS_AREA) {
		if (LIGHT_AREA_DIFFUSE_MULTIPLIER.r > beyer_threshold) {
			DIFFUSE_LIGHT += LIGHT_AREA_DIFFUSE_MULTIPLIER * ATTENUATION * LIGHT_COLOR;
		}
	}
	else {
		diffuse = clamp(dot(LIGHT, NORMAL), 0.0, 1.0);
		if (diffuse > beyer_threshold) {
			DIFFUSE_LIGHT += diffuse * LIGHT_COLOR * ATTENUATION;
		}
	}
	DIFFUSE_LIGHT += emmision_color * ALBEDO;
	
}
