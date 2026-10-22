shader_type canvas_item;
//render_mode blend_mul;


uniform float amount: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float hint_angle: hint_range(0.0, 3.1415 * 2.0, 0.01) = 0.0;
uniform vec4 hint_color: source_color;

uniform sampler2D screen_texture: hint_screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	//COLOR = texture(TEXTURE, UV);
	float dist = distance(SCREEN_UV, vec2(0.5, 0.5));
	float gen_value = mix(1.0 - amount*amount*amount*0.5, 0, mix(dist*dist*dist, dist*dist, dist));
	
	vec2 hint_uv = SCREEN_UV - 0.5;
	float px_angle = (atan(hint_uv.x, hint_uv.y) + hint_angle + PI) / (PI*2.0);
	float hint_px = pow(abs(fract(px_angle) - 0.5) * 2.0, 6.0);
	float center = min((dist - 0.2)*6.0, 1.0);
	float full_hint_shade = (center*hint_px);
	
	float hint_shade_amount = mix(1.0, full_hint_shade, pow(amount, 0.4));
	vec4 clr_texture = mix(vec4(1, 1, 1, 1), texture(TEXTURE, UV) * gen_value, amount);
	
	// TODO: this look funny in tha middle still
	COLOR = mix(texture(screen_texture, SCREEN_UV) * clr_texture, hint_color, full_hint_shade * pow(amount, 0.4));
	

	//COLOR = mix(vec4(1, 1, 1, 1), texture(TEXTURE, UV) * gen_value, amount);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
