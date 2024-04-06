shader_type canvas_item;
uniform sampler2D mask_texture;

void vertex() {

}

void fragment() {
	vec4 mask = texture(mask_texture, UV);
    if (mask.r > 0.5) {
		COLOR = vec4(40.0, 0.0, 0.0, 1.0); 
    } else {
		COLOR = texture(TEXTURE, UV); 
    }
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
