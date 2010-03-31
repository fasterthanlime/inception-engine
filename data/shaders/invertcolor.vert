void main(void) {
	gl_FrontColor = vec4(1) -  gl_Color;
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;
}
