shader_type canvas_item;
render_mode unshaded; // No interaction with light

uniform float cutoff : hint_range(0.0, 1.0); // cutoff point for pixel/shown
uniform float smooth_size : hint_range(0.0, 1.0); // smoothing size for the end
uniform sampler2D mask : hint_albedo; // set transition type

void fragment(){
	float value = texture(mask, UV).r;
	float alpha = smoothstep(cutoff, cutoff + smooth_size, value * (1.0 - smooth_size) + smooth_size); // Fix gap
	COLOR = vec4(COLOR.rgb, alpha);
}