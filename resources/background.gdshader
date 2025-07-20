shader_type canvas_item;

uniform sampler2D gradientTexture;

uniform vec2 resolution = vec2(16.,9.);
uniform float scale: hint_range(0, 500) = 20;
uniform float timeScale: hint_range(0, 10) = 1;
uniform float fbmOctaves: hint_range(0, 10) = 1.0;
uniform float fbmFrequency: hint_range(0, 10) = 2.0;

vec2 random(vec2 uv){
	vec2 value = vec2( dot(uv, vec2(127.1,311.7) ),
				  dot(uv, vec2(269.5,183.3) ) );
	vec2 result =  -1.0 + 2.0 * fract(sin(value) * 43758.5453123);
	return sin(result * TIME * timeScale);
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
	float amplitude = 0.5;
	for (float i = 0.0; i < fbmOctaves; i++) {
		fbmNoise += perlinNoise(uv * frequency) * amplitude;
		amplitude *= 0.5;
		frequency *= 2.0;
	}
	return fbmNoise;
}

float pattern( in vec2 p, out vec2 q, out vec2 r )
{
    q.x = fbm( p + vec2(0.0,0.0) );
    q.y = fbm( p + vec2(5.2,1.3) );

    r.x = fbm( p + 4.0*q + vec2(1.7,9.2) );
    r.y = fbm( p + 4.0*q + vec2(8.3,2.8) );

    return fbm( p + 4.0*r );
}

vec4 getGradientColor(float position) {
    return texture(gradientTexture, vec2(position, 0.5));
}

void fragment() {
	vec2 st = UV/resolution;
	vec2 pos = vec2(scale * st);
	vec2 q = vec2(0);
	vec2 r = vec2(0);
	float noise = pattern(pos, q, r);

	COLOR = getGradientColor(noise);
}
