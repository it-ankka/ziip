shader_type canvas_item;

uniform sampler2D gradientTexture;
uniform float scale: hint_range(0, 500, 1) = 10;
uniform float timeScale: hint_range(0, 10, 0.1) = 1;

uniform int fbmOctaves: hint_range(0, 10) = 1;
uniform float fbmAmplitude: hint_range(0, 10, 0.05) = 0.5;
uniform float fbmFrequency: hint_range(0, 10, 0.25) = 2.0;
uniform int patternIterations: hint_range(0, 3) = 1;

uniform bool applySwirl = true;
uniform float rotationRadius = .5;
uniform float rotationAngle = 6.28318;

vec2 random(vec2 uv){
	vec2 value = vec2( dot(uv, vec2(127.1,311.7) ),
				  dot(uv, vec2(269.5,183.3) ) );
	vec2 result =  -1.0 + 2.0 * fract(sin(value) * 43758.5453123);
	return timeScale > 0.0 ? sin(result * TIME * timeScale) : result;
}

float perlinNoise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) + 0.5;
}


float fbm(vec2 uv) {
	float fbmNoise = 0.0;
	float frequency = fbmFrequency;
	float amplitude = fbmAmplitude;
	for (int i = 0; i < fbmOctaves; i++) {
		fbmNoise += perlinNoise(uv * frequency) * amplitude;
		amplitude *= 0.5;
		frequency *= 2.0;
	}
	return fbmNoise;
}

void pattern( in vec2 p, out vec2 q, out vec2 r )
{
    q.x = fbm( p + vec2(0.0,0.0) );
    q.y = fbm( p + vec2(5.2,1.3) );

    r.x = fbm( p + 4.0*q + vec2(1.7,9.2) );
    r.y = fbm( p + 4.0*q + vec2(8.3,2.8) );

}

vec4 getGradientColor(float position) {
    return texture(gradientTexture, vec2(position, 0.5));
}

vec2 swirlRotate(vec2 uv, vec2 resolution) {
	float len = length(uv * vec2(resolution.x / resolution.y, 1.));
	float angle = atan(uv.y, uv.x) + rotationAngle * smoothstep(rotationRadius * scale, 0., len);
	float radius = length(uv);

	return vec2(radius * cos(angle), radius * sin(angle)) + vec2(.5, .5);
}

void fragment() {
	vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 st = FRAGCOORD.xy / resolution - vec2(.5, .5);
	vec2 pos = vec2(scale * st);
    pos = applySwirl ? swirlRotate(pos, resolution) : pos;
	float val = 0.0;
	if(patternIterations < 1) {
		val = fbm(pos);
	} else {
		vec2 q = vec2(0);
		vec2 r = vec2(0);
		pattern(pos, q, r);

		if(patternIterations == 1)
			val = fbm(pos + 4.0 * q);
		else if(patternIterations >= 2)
			val = fbm(pos + 4.0 * r);
	}

	COLOR = getGradientColor(val);
}
