//uniform float time;

void main(void)
{
    //gl_FrontColor = vec4(1.0) - gl_Color;
	//gl_FrontColor = gl_Color;
    //gl_FrontColor = sin(time/10.0) + 1;
	//gl_Position.x = gl_Vertex.x*sin(time/5.0);
	//gl_Position.y = gl_Vertex.y*sin(time/5.0);
	gl_FrontColor = gl_Color;
	gl_Position = gl_Vertex;
}
