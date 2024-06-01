shader_type canvas_item;

void fragment() {
	// Editable parameters
	float r0 = 0.1; // When r < r0 (ie: center of the card) don't reduce visibility
	float r1 = 0.5; // When r >= r1 ...
	float l = 0.;   // ... reduce visibility by l

	float a = (l-1.)/(r1-r0);
	float b = 1.-a*r0;

	float dx = 0.5-UV.x;
	float dy = 0.5-UV.y;
	float r = sqrt(dx*dx + dy*dy);
	
	float mult = max(min(a*r+b, 1), 0);
	
	COLOR = texture(TEXTURE, UV);
	COLOR.b *= mult;
	COLOR.r *= mult;
	COLOR.g *= mult;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
