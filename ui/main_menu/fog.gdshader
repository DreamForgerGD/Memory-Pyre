shader_type canvas_item;
render_mode unshaded;

// Туман-заглушка: медленно ползущий шум, гуще к низу прямоугольника.
uniform vec4 fog_color : source_color = vec4(0.42, 0.47, 0.58, 1.0);
uniform float density : hint_range(0.0, 1.0) = 0.32;
uniform vec2 speed = vec2(0.015, 0.0);
uniform float noise_scale = 3.0;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x),
			mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int k = 0; k < 4; k++) {
		v += a * noise(p);
		p *= 2.0;
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 uv = UV * vec2(noise_scale * 3.0, noise_scale);
	float warp = fbm(uv + TIME * speed * noise_scale);
	float n = fbm(uv + vec2(warp * 1.5, 0.0) + TIME * speed * noise_scale * 0.5);
	float vertical = smoothstep(0.0, 0.7, UV.y);
	COLOR = vec4(fog_color.rgb, smoothstep(0.25, 0.8, n) * vertical * density);
}
