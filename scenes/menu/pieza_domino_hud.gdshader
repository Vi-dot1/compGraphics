shader_type canvas_item;

uniform vec4 dot_color : source_color = vec4(0.0,0.0,0.0,1.0);
uniform float dot_size = 0.12;
uniform int val1 = 0;
uniform int val2 = 0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453123);
}
float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(hash(i + vec2(0.0,0.0)), hash(i + vec2(1.0,0.0)), u.x),
		mix(hash(i + vec2(0.0,1.0)), hash(i + vec2(1.0,1.0)), u.x),
		u.y
	);
}

float draw_dot(vec2 uv, vec2 pos, float size) {
	float d = length(uv - pos);
	// smooth circle: 0..1 where 1 is center
	return smoothstep(size, size * 0.6, d);
}

float draw_pips(vec2 uv, int val, float size) {
	float res = 0.0;
	if (val == 0) return 0.0;

	if (val % 2 == 1) res += draw_dot(uv, vec2(0.5, 0.5), size);
	if (val >= 2) {
		res += draw_dot(uv, vec2(0.25, 0.25), size);
		res += draw_dot(uv, vec2(0.75, 0.75), size);
	}
	if (val >= 4) {
		res += draw_dot(uv, vec2(0.25, 0.75), size);
		res += draw_dot(uv, vec2(0.75, 0.25), size);
	}
	if (val == 6) {
		res += draw_dot(uv, vec2(0.25, 0.5), size);
		res += draw_dot(uv, vec2(0.75, 0.5), size);
	}
	return clamp(res, 0.0, 1.0);
}

void fragment() {
	vec2 uv = UV; // 0..1
	float half = 0.5;
	float mask = 0.0;
	if (uv.x < half) {
		vec2 local_uv = vec2(uv.x / half, uv.y);
		mask = draw_pips(local_uv, val1, dot_size);
	} else {
		vec2 local_uv = vec2((uv.x - half) / half, uv.y);
		mask = draw_pips(local_uv, val2, dot_size);
	}

	// Only render the dots; background transparent
	vec3 col = dot_color.rgb;
	float a = dot_color.a * mask;

	COLOR = vec4(col, a);
}
