shader_type canvas_item;

uniform sampler2D portal_texture : hint_screen_texture;
uniform vec2 sample_offset;

void fragment() {
    vec2 portal_uv = SCREEN_UV;
	portal_uv.x + 1.0;


    COLOR = texture(TEXTURE, portal_uv);
}