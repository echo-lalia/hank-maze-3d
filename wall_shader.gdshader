shader_type spatial;

uniform float GENERATED_TEXTURE_WIDTH_MULT = 0.2;
uniform float GENERATED_TEXTURE_HEIGHT_MULT = -0.25;
uniform float GENERATED_TEXTURE_HEIGHT_ADD = 0.5;
uniform sampler2D wall_texture: filter_nearest;

void vertex() {
	// Called for every vertex the material is visible on.
	COLOR.r = (VERTEX.x + VERTEX.z) * GENERATED_TEXTURE_WIDTH_MULT;
	COLOR.y = VERTEX.y * GENERATED_TEXTURE_HEIGHT_MULT + GENERATED_TEXTURE_HEIGHT_ADD;
}

void fragment() {
	// Called for every pixel the material is visible on.
	
	ALBEDO = texture(wall_texture, vec2(COLOR.r, COLOR.y)).rgb;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
