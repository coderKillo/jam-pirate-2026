shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0, 0.9, 0.65, 0.8);
uniform vec3 threshold;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
void fragment() {
	vec4 orig_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	if (orig_color.r > threshold.x &&orig_color.g < threshold.y &&orig_color.b < threshold.z) {
		COLOR = orig_color * color;
	}
	else {
		COLOR = orig_color;
	}
}
