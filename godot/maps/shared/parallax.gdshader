shader_type canvas_item;

uniform bool enabled = false;
uniform float speed = 0.0;

void vertex() {
}

void fragment() {
	if (enabled == true) {
		vec2 newuv = UV;
		newuv.x += speed;
		vec4 c = texture(TEXTURE, newuv);
		COLOR = c;
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
