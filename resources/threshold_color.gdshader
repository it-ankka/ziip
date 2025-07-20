shader_type canvas_item;

uniform float difference_point = 1.0; //pixel brightness coefficient
uniform vec4 first_color: source_color = vec4(1,1,1,1);
uniform vec4 second_color: source_color = vec4(0,0,0,1);
uniform int blur_strength: hint_range(0, 16) = 1;

vec4 threshold_color(vec4 color) {
    vec4 col = (dot(color, vec4(0.5, 0.5, 0.5, 0)) < difference_point)
    	? vec4(second_color.rgb,second_color.a*color.a)
    	: vec4(first_color.rgb,first_color.a*color.a);
	return col;
}

vec4 threshold_and_box_blur(sampler2D tex,vec2 fragCoord, vec2 pixelSize) {

    vec4 color = vec4(0.,0.,0.,0.);
    float strengthFloat = float(blur_strength);

    vec2 pixel = fragCoord/pixelSize;
    int x_min = max(int(pixel.x-strengthFloat), 0);
    int x_max = min(int(pixel.x+strengthFloat), int(1./pixelSize.x));
    int y_min = max(int(pixel.y-strengthFloat), 0);
    int y_max = min(int(pixel.y+strengthFloat), int(1./pixelSize.y));

    int count = 0;

    // Sum the pixels colors
    for(int x=x_min; x <= x_max; x++) {
		vec4 col = texture(tex, vec2(float(x), float(pixel.y)) * pixelSize);
		color += threshold_color(col);
		count++;
    }

	for(int y = y_min; y <= y_max; y++) {
		if(pixel.y == float(y)) continue;
		vec4 col = texture(tex, vec2(float(pixel.x), float(y)) * pixelSize);
		color += threshold_color(col);
		count++;
	}

    // Divide the color by the number of colors you summed up
    color /= float(count);

    return color;
}

void fragment() {
	COLOR = COLOR.a > 0.5
		? threshold_and_box_blur(TEXTURE, UV, TEXTURE_PIXEL_SIZE)
		: COLOR ;
}