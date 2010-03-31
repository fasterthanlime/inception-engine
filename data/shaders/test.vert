void main(void)
{
	//gl_FrontColor = vec4(1.0) - gl_Color;
	gl_FrontColor = gl_Color;
	gl_Position = gl_Vertex;
	
}
