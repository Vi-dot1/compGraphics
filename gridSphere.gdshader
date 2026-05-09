shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never;

uniform vec4 line_color : source_color = vec4(0.0, 1.0, 0.0, 1.0);
uniform float line_thickness : hint_range(0.0, 1.0) = 0.2;
uniform float grid_density = 1.0;

varying vec3 v_world_pos;

void vertex() {
    v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec3 pos = v_world_pos * grid_density;
    vec3 fw = max(fwidth(pos), vec3(0.0001));
    vec3 grid = abs(fract(pos - 0.5) - 0.5) / fw;
    float line = min(grid.x, min(grid.y, grid.z));
    float final_line = smoothstep(line_thickness, line_thickness + 1.0, line);
    ALBEDO = line_color.rgb;
    ALPHA = 1.0 - final_line;
}
