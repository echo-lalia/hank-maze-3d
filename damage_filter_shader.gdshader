shader_type canvas_item;
render_mode blend_mul;


uniform float amount = 1.0;


void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//COLOR = texture(TEXTURE, UV);
	COLOR = mix(vec4(1, 1, 1, 1), texture(TEXTURE, UV), amount);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
