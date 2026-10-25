shader_type spatial;

uniform vec3 color: source_color;



void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = color;
}
