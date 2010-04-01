import glew

SProgram: class {  //stands for shader program
	program: GLuint
	timeid: GLuint
	init: func(=program) {
		timeid = glGetUniformLocation(program,"time")
	} 

	del: func {
		glDeleteProgram(program)
	}
}

