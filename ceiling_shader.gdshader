// NOTE: Shader automatically converted from Godot Engine 4.8.beta1's StandardMaterial3D.

shader_type spatial;
//render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;


uniform sampler2D texture_albedo : source_color, filter_nearest, repeat_enable;

uniform sampler2D texture_metallic : hint_default_white, filter_nearest, repeat_enable;
uniform vec4 metallic_texture_channel;

uniform float specular : hint_range(0.0, 1.0, 0.01);
uniform float metallic : hint_range(0.0, 1.0, 0.01);

global uniform sampler2D beyer_matrix: filter_nearest;
global uniform float viewport_width_beyer;
global uniform float viewport_height_beyer;

uniform vec3 uv1_scale;
uniform vec3 uv1_offset;


void vertex() {
	UV = UV * uv1_scale.xy + uv1_offset.xy;
}

void fragment() {
	vec2 base_uv = UV;

	vec4 albedo_tex = texture(texture_albedo, base_uv);

	// Albedo Texture Force sRGB: Enabled
	albedo_tex.rgb = mix(
			pow((albedo_tex.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)),
			albedo_tex.rgb.rgb * (1.0 / 12.92),
			lessThan(albedo_tex.rgb, vec3(0.04045)));
	ALBEDO = albedo_tex.rgb;
}


void light() {
	float beyer_threshold = texture(beyer_matrix, SCREEN_UV * vec2(viewport_width_beyer, viewport_height_beyer)).r;
	
	// https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/spatial_shader.html#light-built-ins
	if (LIGHT_IS_AREA) {
		if (LIGHT_AREA_DIFFUSE_MULTIPLIER.r > beyer_threshold) {
			DIFFUSE_LIGHT += LIGHT_AREA_DIFFUSE_MULTIPLIER * ATTENUATION * LIGHT_COLOR;
		}
		if ((LIGHT_AREA_SPECULAR_MULTIPLIER * ATTENUATION * SPECULAR_AMOUNT).r > beyer_threshold) {
			SPECULAR_LIGHT += LIGHT_AREA_SPECULAR_MULTIPLIER * ATTENUATION * LIGHT_COLOR * SPECULAR_AMOUNT;
		}
	}
	else {
		float diffuse = clamp(dot(LIGHT, NORMAL), 0.0, 1.0);
		if (diffuse > beyer_threshold) {
			DIFFUSE_LIGHT += diffuse * LIGHT_COLOR * ATTENUATION;
		}
		float specular_amount = pow(dot(NORMAL, normalize(LIGHT + VIEW)), 50.0);
		if (specular_amount > beyer_threshold) {
			SPECULAR_LIGHT += specular_amount * LIGHT_COLOR * ALBEDO * SPECULAR_AMOUNT * ATTENUATION;
		}
	}
	
}
