uniform float time;
void main(void) {
	gl_FrontColor = gl_Color;
	gl_Position = ftransform();
}
