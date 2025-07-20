shader_type canvas_item;

uniform float blur_size = 2.0;
uniform vec4 glow_color : source_color;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


void fragment() {
    vec2 size = vec2(blur_size) / SCREEN_PIXEL_SIZE;
    vec4 sum = vec4(0.0);
    sum += texture(SCREEN_TEXTURE, SCREEN_UV + size * vec2(-1.0, -1.0)) * 0.05;
    sum += texture(SCREEN_TEXTURE, SCREEN_UV + size * vec2(0.0, -1.0)) * 0.09;
    sum += texture(SCREEN_TEXTURE, SCREEN_UV + size * vec2(1.0, -1.0)) * 0.05;

    sum += texture(SCREEN_TEXTURE, SCREEN_UV + size * vec2(-1.0, 0.0)) * 0.09;
    sum += texture(SCREEN_TEXTURE, SCREEN_UV + size * vec2(0.0, 0.0)) * 0.16;
    sum += texture(SCREEN_TEXTURE, SCREEN_UV + size * vec2(1.0, 0.0)) * 0.09;

    sum += texture(SCREEN_TEXTURE, SCREEN_UV + size * vec2(-1.0, 1.0)) * 0.05;
    sum += texture(SCREEN_TEXTURE, SCREEN_UV + size * vec2(0.0, 1.0)) * 0.09;
    sum += texture(SCREEN_TEXTURE, SCREEN_UV + size * vec2(1.0, 1.0)) * 0.05;

    COLOR = sum * glow_color;
}
