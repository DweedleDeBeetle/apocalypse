shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_texture : source_color, hint_screen_texture, filter_nearest;
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

void vertex() {
	POSITION = vec4(VERTEX.xy,1.0,1.0);
}

void fragment() {
	vec3 original = texture(screen_texture,SCREEN_UV).rgb;
	vec4 screen = texture(screen_texture, SCREEN_UV);
	vec3 hsv = rgb2hsv(original);
	
	hsv.z = posterize(hsv.z, steps);
	
	vec3 rgb = hsv2rgb(hsv);
	
	ALBEDO = mix(original, vec3(0),rgb);
}