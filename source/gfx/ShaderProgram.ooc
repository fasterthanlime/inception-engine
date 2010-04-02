import glew

ShaderProgram: class {  //stands for shader program

	id: GLuint
	timeid: GLuint
    
	init: func(=id) {
		timeid = glGetUniformLocation(id, "time")
	} 

	del: func {
		glDeleteProgram(id)
	}
    
}

