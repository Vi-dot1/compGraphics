shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo : source_color = vec4(0.9, 0.9, 0.9, 1.0);
uniform vec4 pip_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 edge_color : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform float emission_strength : hint_range(0.0, 10.0) = 0.0;

uniform int val1 = 0;
uniform int val2 = 0;

varying vec3 world_pos;
varying vec3 local_pos;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
			   mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
	float res = 0.0;
	float amp = 0.5;
	for (int i = 0; i < 4; i++) {
		res += amp * noise(p);
		p *= 2.0;
		amp *= 0.5;
	}
	return res;
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	local_pos = VERTEX;
}

float draw_dot(vec2 uv, vec2 pos) {
	float d = length(uv - pos);
	return smoothstep(0.08, 0.06, d);
}

float draw_pips(vec2 uv, int val) {
	float res = 0.0;
	if (val == 0) return 0.0;
	
	if (val % 2 == 1) res += draw_dot(uv, vec2(0.5, 0.5));
	if (val >= 2) {
		res += draw_dot(uv, vec2(0.25, 0.25));
		res += draw_dot(uv, vec2(0.75, 0.75));
	}
	if (val >= 4) {
		res += draw_dot(uv, vec2(0.25, 0.75));
		res += draw_dot(uv, vec2(0.75, 0.25));
	}
	if (val == 6) {
		res += draw_dot(uv, vec2(0.25, 0.5));
		res += draw_dot(uv, vec2(0.75, 0.5));
	}
	return res;
}

void fragment() {
	vec2 uv = local_pos.xz + vec2(1.0, 0.5);
	
	float mask = 0.0;
	if (uv.x < 1.0) {
		mask = draw_pips(uv, val1);
	} else {
		mask = draw_pips(uv - vec2(1.0, 0.0), val2);
	}
	
	// Simple clean albedo for white dominoes
	vec3 base_albedo = albedo.rgb;
	
	// Edge glow (border)
	float edge = 0.0;
	edge += smoothstep(0.42, 0.45, abs(local_pos.z));
	edge += smoothstep(0.92, 0.95, abs(local_pos.x));
	
	ALBEDO = mix(base_albedo, pip_color.rgb, mask);
	EMISSION = edge_color.rgb * edge * emission_strength;
	METALLIC = 0.1;
	ROUGHNESS = 0.8;
}
