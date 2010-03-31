use glew,sdl,glu
import glew
import glu/Glu
import sdl/Video
import engine/[Entity, Update, Engine, Types]
import gfx/[Model, RenderWindow, Camera, SProgram]
import structs/[LinkedList, HashMap]
import io/[File, FileReader]
import text/Buffer

include unistd
usleep: extern func(Int)

Scene: class extends Entity {
	
	models := HashMap<String,Model> new()
	shaders := HashMap<String, Int> new()
	programs := HashMap<String, Int> new()  //shader programs
	
	globalPrograms := LinkedList<String> new()
	
	round : Long = 0
	
	init: func ~scene(.name) {
		super(name)
		this addUpdate(Update new(This render))
		set("camera",Camera new(Float3 new(10,10,10),Float3 new(0,0,0),"default_cam"))
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
		printf("==================== render %ld ===================\n",round)
		cam := get("camera",Camera) .look()
		
		for(name in globalPrograms) {
			useProgram(name)
			printf("using program %s\n",name)
		}

	    
	    for(model in models) {
            model _render()
		}
		for(name in globalPrograms) {
			glUseProgram(0)
		}
		
	    glFlush()
	    SDLVideo glSwapBuffers()
	    usleep(30000)
	    round += 1
		
	    return true
	}
	
	onAdd: func {
		engine addEntity(get("camera",Camera))
	}
	
	addProgram: func(name: String) {
		globalPrograms add(name)
	}
	
	setProgram: func(name,model: String) {
		prg := programs get(name)
		if(prg == null) {
			printf("[Scene->setProgram]: No such program '%s'\n",name)
			return
		}
		
		mod := models get(model)
		if(mod == null) {
			printf("[Scene->setProgram]: No such model '%s'\n",model)
			return
		}
			
		mod setProgram(prg)		
	}
	
	useProgram: func(name: String) {
		prg := programs get(name)
		if(prg != null)
			glUseProgram(prg)
	}
	
	addShader: func(name: String, filename: String, type: GLenum) {
		
		printf("creating shader %s at %s\n",name,filename)
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
			printf("=====================================\n")
			printf("%s\n",src)
			printf("=====================================\n")
			printf("\t%s\n",log)
			glDeleteShader(shader)
			return
		}
		
		shaders put(name, shader)
		
	}
	
	loadSrc: func(filename: String) -> String {
		reader := FileReader new(File new("data/shaders/test.vert"))
		buffer := Buffer new()
		while(reader hasNext()) {
			buffer append(reader read())
		}
		
		src := buffer toString() clone()
		src[src length() - 1] = '\0'
		
		return src
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
	
	createProgram: func ~vertex(name,pshader,vshader: String) -> Bool {
		if(pshader == null && vshader == null) {
			Exception new("[Scene->addProgram]: Passed only null arguments") throw()
		}
		
		link_status := GL_TRUE
		vsh : GLuint = 0
		psh : GLuint = 0
		logsize : GLint = 0
		log: String
		
		if(pshader != "" && pshader != null) {
			psh = shaders get(pshader)
			if(psh == null)
				return false
		}
			
		if(vshader != "" && vshader != null) {
			vsh = shaders get(vshader)
			if(vsh == null)
				return false
		}
		
		program := glCreateProgram()
		
		if(vsh) {
			glAttachShader(program, vsh)
		}
		if(psh) {
			glAttachShader(program, psh)
		}
			
		glLinkProgram(program)
		
		glGetProgramiv(program, GL_LINK_STATUS, link_status&)
		if(link_status != GL_TRUE) {
			glGetProgramiv(program, GL_INFO_LOG_LENGTH, logsize&);
			log = String new(logsize)
			
			glGetProgramInfoLog(program, logsize, logsize&, log);
			
			fprintf(stderr, "impossible de lier le program :\n%s", log)
			
			glDeleteProgram(program)
			glDeleteShader(vsh)
			glDeleteShader(psh)
			return false
		}
		
		programs put(name,program)
		return true
	}
}
