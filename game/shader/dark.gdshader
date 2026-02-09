shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.0, 0.9, 0.65, 0.8);
uniform float threshold: hint_range(0.0, 1.0);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
void fragment() {
	vec4 orig_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	if (orig_color.r > threshold && orig_color.r > orig_color.g && orig_color.r > orig_color.b) {
		COLOR = orig_color;
	}
	else {
		COLOR = orig_color * color;
	}
}
