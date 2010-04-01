uniform float time;

void main(void) {
	vec4 color = gl_Color;
	
	
	color.x = color.x*abs(sin(time/10.0));
	//color.x = 0.0;
	/*
	color.y = color.y + cos(gl_FragCoord.y)/20.0;
	*/
	gl_FragColor = color;
}
