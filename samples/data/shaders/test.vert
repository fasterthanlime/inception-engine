uniform float time;

void main(void) {
	//gl_FrontColor = sin(time/100)/2.0 + 0.5;
	gl_FrontColor = gl_Color;
    vec4 inter = gl_Vertex;
	inter.x = inter.x * sin(time/200);
	inter.y = inter.y * sin(time/300);
	inter.z = inter.z * sin(time/250);
	inter = gl_ModelViewProjectionMatrix * inter;
	gl_Position = inter;
}
