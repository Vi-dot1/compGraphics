shader_type canvas_item;

uniform int bits = 5;
uniform bool dithering = true;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float dither4x4(vec2 position) {
    int x = int(mod(position.x, 4.0));
    int y = int(mod(position.y, 4.0));

    int index = x + y * 4;

    float[16] matrix = float[](
        0.0, 8.0, 2.0, 10.0,
        12.0, 4.0, 14.0, 6.0,
        3.0, 11.0, 1.0, 9.0,
        15.0, 7.0, 13.0, 5.0
    );

    return matrix[index] / 16.0;
}

void fragment() {

    vec4 col = texture(SCREEN_TEXTURE, SCREEN_UV);

    float levels = float(1 << bits);

    if (dithering) {
        float d = dither4x4(FRAGCOORD.xy);
        col.rgb += d / levels;
    }

    col.rgb = floor(col.rgb * levels) / levels;

    COLOR = col;
}