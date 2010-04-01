uniform float time;

float rand(vec2 co){
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}


void main(void) {
	vec4 color = gl_Color;
	
	
	color.x = 1 - exp(-color.x);
	
	
	//color = vec4(1) - gl_Color;
	
	
	gl_FragColor = color;
}
