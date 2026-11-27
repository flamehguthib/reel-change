shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap, repeat_disable;
uniform float blur_amount : hint_range(0.0, 4.0) = 1.8;
uniform vec4 glass_tint : source_color = vec4(0.85, 0.95, 1.0, 0.35);

void fragment() {
	vec4 blurred_bg = textureLod(screen_texture, SCREEN_UV, blur_amount);
	// Blend blurred background with your StyleBoxFlat color/border
	COLOR = mix(blurred_bg, COLOR * glass_tint, glass_tint.a);
}


//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
