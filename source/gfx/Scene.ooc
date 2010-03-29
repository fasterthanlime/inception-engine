use glew,sdl,glu
import glew
import glu/Glu
import sdl/Video
import engine/[Entity, Update, Engine, Types]
import gfx/[Model, RenderWindow, Camera]
import structs/[LinkedList, HashMap]
import io/File

include unistd
usleep: extern func(Int)

Scene: class extends Entity {
	
	models := LinkedList<Model> new()
	shaders := HashMap<String, Int> new()
	
	
	
	init: func ~scene(.name) {
		super(name)
		this addUpdate(Update new(This render))
		set("camera",Camera new("default_cam"))
	}
	
	render: func -> Bool {
		
		glClearColor(0,0,0,0)
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
	    //glMatrixMode(GL_MODELVIEW)
	    //glLoadIdentity()
	    //rw := engine getEntity("render_window") as RenderWindow 
	    
	    //glMatrixMode(GL_PROJECTION);
		//glLoadIdentity();
		//gluPerspective(45.0, rw width/rw height, 1.0, 10000.0);
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity()
		
		cam := get("camera",Camera) .look()

	    
	    for(model in models) {
			model render()
		}
	    
	    SDLVideo glSwapBuffers()
	    usleep(30000)
	    return true
	}
	
	onAdd: func {
		engine addEntity(get("camera",Camera))
	}
	
	addShader: func(name: String, filename: String, type: GLenum) {
		
		if(type != GL_VERTEX_SHADER && type != GL_FRAGMENT_SHADER) {
			printf("[Engine]: Error, unkown shader type\n")
			return
		}
		
		shader := glCreateShader(type)
		logsize : GLsizei = 0
		compile_status : GLint = GL_TRUE
		
		
		if(shader == 0) {
			printf("[Engine]: Error, could not create shader '%s'\n",name)
			glDeleteShader(shader)
			return
		}
		
		src := loadSrc(filename)
		if(src == null) {
			printf("[Engine]: Error in loading shader source ( %s )\n",filename)
			glDeleteShader(shader)
			return
		}
		
		glShaderSource(shader, 1, src&, null)
		glCompileShader(shader)
		
		glGetShaderiv(shader, GL_COMPILE_STATUS, compile_status&)
		if( compile_status != GL_TRUE ) {
			glGetShaderiv(shader, GL_INFO_LOG_LENGTH, logsize&)
			
			log := String new(logsize)
			
			glGetShaderInfoLog(shader, logsize, logsize&, log)
			printf("[Engine]: Error while compiling shader '%s'\n",filename)
			printf("\t%s\n",log)
			glDeleteShader(shader)
			return
		}
		
		shaders put(name, shader)
		
	}
	
	loadSrc: func(filename: String) -> String {
		return File new(filename) read()
	}
	
	delShader: func(name: String) {
		shader := shaders get(name)
		if(name == null) {
			printf("[Engine]: Error, shader inexistent\n")
			return
		}
		glDeleteShader(shader)
		shaders remove(name)
	}
}
