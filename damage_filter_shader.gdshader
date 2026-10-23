shader_type canvas_item;
//render_mode blend_mul;


uniform float amount: hint_range(0.0, 1.0, 0.001) = 1.0;
uniform float hint_angle: hint_range(0.0, 3.1415 * 2.0, 0.01) = 0.0;
uniform vec4 hint_color: source_color;

uniform sampler2D screen_texture: hint_screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

vec4 overlay_color(vec4 a, vec4 b) {
	//vec4 sw = vec4(lessThan(a, vec4(0.5)));
	// mix multiply and screen blend modes based on `a` value.
	return mix(
		2.0 * a * b,
		1.0 - 2.0 * (1.0 - a) * (1.0 - b),
		vec4(greaterThan(a, vec4(0.5)))
	);
}

void fragment() {
	//COLOR = texture(TEXTURE, UV);
	float dist = distance(SCREEN_UV, vec2(0.5, 0.5));
	float gen_value = mix(1.0 - amount*amount*amount*0.5, 0, mix(dist*dist*dist, dist*dist, dist));
	
	vec2 hint_uv = SCREEN_UV - 0.5;
	float px_angle = (atan(hint_uv.x, hint_uv.y) + hint_angle + PI) / (PI*2.0);
	float hint_px = pow(abs(fract(px_angle) - 0.5) * 2.0, 6.0);
	hint_px = smoothstep(0.0, 0.666, hint_px);
	//float center = min((dist - 0.2)*6.0, 1.0);
	float center = min(smoothstep(dist, -0.1, 0.2), 1);
	float full_hint_shade = (center*hint_px);
	
	float hint_shade_amount = mix(0.0, full_hint_shade, pow(amount, 1));
	vec4 clr_texture = mix(vec4(1, 1, 1, 1), texture(TEXTURE, UV) * gen_value, pow(amount, 3.0));
	
	
	//COLOR = vec4(hint_px);
	//COLOR = mix(texture(screen_texture, SCREEN_UV) * clr_texture, hint_color, clamp(hint_shade_amount, 0, 1));
	//COLOR = (texture(screen_texture, SCREEN_UV) * clr_texture) * clamp(hint_color * hint_shade_amount, 0, 1);
	vec4 clr_texture_blended = texture(screen_texture, SCREEN_UV) * clr_texture;

	COLOR = mix(clr_texture_blended, hint_color, clamp(hint_shade_amount, 0, 1));
	
	//COLOR = vec4(center);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
