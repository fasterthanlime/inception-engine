import glew

SProgram: class {  //stands for shader program
	vertexShader, fragmentShader: GLuint
	program: GLuint
	init: func(=fragmentShader,=vertexShader) {
		program = glCreateProgram()
	} 

	del: func {
		glDeleteProgram(program)
	}
}

