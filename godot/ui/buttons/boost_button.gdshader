shader_type canvas_item;

uniform bool enabled = false;
uniform vec4 color: source_color;
uniform float speed : hint_range(0.1, 5.0) = 1.0;
uniform float frequency : hint_range(1.0, 20.0) = 10.0;
uniform float amplitude : hint_range(0.0, 0.1) = 0.005;
uniform bool vertical_wave = false;

void fragment() {
	// Create wave distortion
	vec2 wave_uv = UV;
	
	if (enabled) {
	    if (vertical_wave) {
	        wave_uv.y += sin(UV.x * frequency + TIME * speed) * amplitude;
	    } else {
	        wave_uv.x += sin(UV.y * frequency + TIME * speed) * amplitude;
	    }
	}
	
	// Sample the texture with the wave distortion
	vec4 texture_color = texture(TEXTURE, wave_uv);
	vec4 uni_color = color;
	uni_color.a = texture_color.a;
	COLOR = mix(texture_color, uni_color, 1.0);
}