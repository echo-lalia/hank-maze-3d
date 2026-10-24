shader_type spatial;

uniform float GENERATED_TEXTURE_WIDTH_MULT = 0.2;
uniform float GENERATED_TEXTURE_HEIGHT_MULT = -0.25;
uniform float GENERATED_TEXTURE_HEIGHT_ADD = 0.5;
uniform sampler2D wall_texture: filter_nearest;

global uniform sampler2D beyer_matrix: filter_nearest;
global uniform float viewport_width_beyer;
global uniform float viewport_height_beyer;

void vertex() {
	// Called for every vertex the material is visible on.
	COLOR.r = (VERTEX.x + VERTEX.z) * GENERATED_TEXTURE_WIDTH_MULT;
	COLOR.y = VERTEX.y * GENERATED_TEXTURE_HEIGHT_MULT + GENERATED_TEXTURE_HEIGHT_ADD;
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	ALBEDO = texture(wall_texture, vec2(COLOR.r, COLOR.y)).rgb;
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
	
}
