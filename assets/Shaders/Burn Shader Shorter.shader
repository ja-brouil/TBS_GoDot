shader_type canvas_item;

// Color Value in inspector
uniform vec4 ash : hint_color;
uniform vec4 fire : hint_color;

// Amount of iterations for noise
uniform int OCTAVES = 6;

// values that need to be set from a script
uniform float start_time = 5;
uniform float duration = 1.0;

float rand(vec2 coord){
	return fract(sin(dot(coord, vec2(12.9898, 78.233)))* 43758.5453123);
}

// Noise texture
float noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);

	// 4 corners of a rectangle surrounding our point
	float a = rand(i);
	float b = rand(i + vec2(1.0, 0.0));
	float c = rand(i + vec2(0.0, 1.0));
	float d = rand(i + vec2(1.0, 1.0));

	vec2 cubic = f * f * (3.0 - 2.0 * f);

	return mix(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
}

// More Detail
float fbm(vec2 coord){
	float value = 0.0;
	float scale = 0.5;

	for(int i = 0; i < OCTAVES; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	return value;
}

vec4 burn(vec4 original, vec2 uv, float time) {
	
	vec4 new_col = original; // value that will be returned
	
	float noise = fbm(uv * 6.0);
	
	float thickness = 0.1;
	float outer_edge = (time - start_time) / duration;
	float inner_edge = outer_edge + thickness;
	
	// fade-in to the orange/black gradient
	if (noise < inner_edge) {
		float grad_factor = (inner_edge - noise) / thickness;
		grad_factor = clamp(grad_factor, 0.0, 1.0);
		vec4 fire_grad = mix(fire, ash, grad_factor);
		
		float inner_fade = (inner_edge - noise) / 0.02;
		inner_fade = clamp(inner_fade, 0.0, 1.0);
		
		new_col = mix(new_col, fire_grad, inner_fade);
	}
	
	// fade-out of the black at the end of the gradient
	if (noise < outer_edge) {
		new_col.a = 1.0 - (outer_edge - noise) / 0.03;
		new_col.a = clamp(new_col.a, 0.0, 1.0);
	}
	
	new_col.a *= original.a;
	return new_col;
}

void fragment() {
	vec4 tex = textureLod(TEXTURE, UV, 0.0);
	COLOR = tex;
	
	COLOR = burn(COLOR, UV, TIME);
}

//void fragment(){
//	// Texture Level of blurryness - Use this to preserve the hidden pixels
//	vec4 tex = textureLod(TEXTURE, UV, 0.0);
//	COLOR = tex;
//
//	// Generate Noise
//	float noise = fbm(UV * 6.0);
//
//	// Thresholds
//	float thickness = 0.1;
//	float outer_edge = (TIME - start_time) / duration; // Formula for animation
//	float inner_edge = outer_edge + thickness;
//
//	// Set color to invisible
//	if (noise < inner_edge){
//		float gradient_factor = (inner_edge - noise) / thickness;
//		gradient_factor = clamp(gradient_factor, 0.0, 1.0);
//		vec4 fire_grad = mix(fire, ash, gradient_factor);
//
//		// Short fade in, use 0.02
//		float inner_fade = (inner_edge - noise) / 0.02;
//		inner_fade = clamp(inner_fade, 0.0, 1.0);
//
//		// Set gradient
//		COLOR = mix(COLOR, fire_grad, inner_fade)
//
//	}
//
//	// Fade to transparency
//	if (noise < outer_edge) {
//		COLOR.a =  1.0 - (outer_edge - noise) / 0.02;
//		COLOR.a = clamp(COLOR.a, 0.0, 1.0);
//	}
//
//	// Set back to transparent
//	COLOR.a *= tex.a;
//}