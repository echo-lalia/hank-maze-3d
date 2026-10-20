shader_type canvas_item;
render_mode blend_mul;


uniform float amount: hint_range(0.0, 1.0, 0.1) = 1.0;

uniform sampler2D screen_texture: hint_screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//COLOR = texture(TEXTURE, UV);
	float dist = distance(SCREEN_UV, vec2(0.5, 0.5));
	float gen_value = mix(1.0 - amount*amount*amount*0.5, 0, mix(dist*dist*dist, dist*dist, dist));

	COLOR = mix(vec4(1, 1, 1, 1), texture(TEXTURE, UV) * gen_value, amount);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
