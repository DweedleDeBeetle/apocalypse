shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : source_color, hint_screen_texture, filter_nearest;
uniform sampler2D depth_texture : source_color, hint_depth_texture, filter_nearest;
uniform sampler2D normal_texture : source_color, hint_normal_roughness_texture, filter_nearest;

uniform float depth_threshold : hint_range(0, 1) = 0.05;

uniform float steps = 16.0;

vec3 rgb2hsv(vec3 c)
{
	vec4 k = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, k.wz), vec4(c.gb, k.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e),q.x);
}

vec3 hsv2rgb(vec3 c)
{
	vec4 k = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + k.xyz) * 6.0 - k.www);
	return c.z * mix(k.xxx,clamp(p - k.xxx, 0.0, 1.0), c.y);
}

float posterize(float val, float levels)
{
	return round(val * levels) / levels;
}

float get_depth(vec2 screen_uv, mat4 inv_projection_matrix) {
	float depth = texture(depth_texture, screen_uv).r;
	vec3 ndc = vec3(screen_uv * 2.0 - 1.0, depth);
	vec4 view = inv_projection_matrix * vec4(ndc, 1.0);
	view.xyz /= view.w;
	return -view.z;
}

void vertex() {
	POSITION = vec4(VERTEX.xy,1.0,1.0);
}

void fragment() {
	//depth outlines
	float depth = get_depth(SCREEN_UV,INV_PROJECTION_MATRIX);
	vec2 texel_size = 1.0 / VIEWPORT_SIZE.xy;

	vec2 uvs[4];
	uvs[0] = vec2(SCREEN_UV.x, SCREEN_UV.y + texel_size.y);
	uvs[1] = vec2(SCREEN_UV.x, SCREEN_UV.y - texel_size.y);
	uvs[2] = vec2(SCREEN_UV.x + texel_size.x, SCREEN_UV.y);
	uvs[3] = vec2(SCREEN_UV.x - texel_size.x, SCREEN_UV.y);

	float depth_diff = 0.0;
	for (int i = 0; i<4; i++) {
		float dep = get_depth(uvs[i], INV_PROJECTION_MATRIX);
		depth_diff += depth - dep;
	}
	float depth_edge = step(depth_threshold, depth_diff);

	vec3 original = texture(screen_texture, SCREEN_UV).rgb;

	vec3 hsv = rgb2hsv(original);

	hsv.z = posterize(hsv.z, steps);

	vec3 rgb = hsv2rgb(hsv);

	vec3 new_original = mix(original, vec3(0), depth_edge);
	ALBEDO = mix(new_original, vec3(0), rgb);
}
