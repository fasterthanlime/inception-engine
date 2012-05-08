use glew,sdl,glu
import glew
import glu/Glu
import sdl/[Video,Core]
import engine/[Entity, Update, Engine, Types]
import gfx/[Model, RenderWindow, Camera, ShaderProgram]
import structs/[LinkedList, HashMap, ArrayList]
import io/[File, FileReader]

include unistd
usleep: extern func(Int)

Pass: class {
    models := ArrayList<Model> new()
    
    add: func (model: Model) { models add(model) }
}

Scene: class extends Entity {
	
    passes := ArrayList<Pass> new()
    backPass, mainPass, frontPass: Pass
    
	shaders := HashMap<String, Int> new()
	programs := HashMap<String, ShaderProgram> new()
	globalPrograms := HashMap<String, ShaderProgram> new()
	
	time1 : UInt32 = 0
	time2 : UInt32 = 0
	fps : UInt32 = 0
	
	round : Long = 0
	
	init: func ~scene(.name) {
		super(name)
		this addUpdate(Update new(This render))
        
        backPass  = Pass new()
        mainPass  = Pass new()
        frontPass = Pass new()
        passes add(backPass). add(mainPass). add(frontPass)
        
		set("camera", Camera new(Float3 new(10, 10, 10), Float3 new(0, 0, 0), "default_cam"))
	}
    
    getBackPass : func -> Pass { backPass }
    getMainPass : func -> Pass { mainPass  }
    getFrontPass: func -> Pass { frontPass }
	
	render: func -> Bool {
            time2 = SDL getTicks()
            glClearColor(0,0,0,0)
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
	    //glMatrixMode(GL_MODELVIEW)
	    //glLoadIdentity()
	    rw := engine getEntity("render_window") as RenderWindow 
	    
	    //glMatrixMode(GL_PROJECTION);
            //glLoadIdentity();
            //gluPerspective(45.0, rw width/rw height, 1.0, 10000.0);
            glMatrixMode(GL_MODELVIEW);
            glLoadIdentity()
		
            cam := get("camera", Camera) .look()
		
            // this is probably wrong. I think we can only use one shader at a time
            for(shader in globalPrograms) {
                    useProgram(shader)
            }

	    for(pass in passes) {
                for(model in pass models) {
                    model _render()
                }
            }
        
            for(shader in globalPrograms) {
                    glUseProgram(0)
            }
		
	    glFlush()
	    SDLVideo glSwapBuffers()

            time1 = SDL getTicks()
            ticksPerFrame := 100
            delta := time1 - time2
            sleepTime := (ticksPerFrame - delta) * 100

            if (sleepTime < 0) {
                // woops, late
                sleepTime = 0
            }
            usleep(sleepTime)
		
	    return true
	}
	
	onAdd: func {
		engine addEntity(get("camera",Camera))
	}
	
	addProgram: func(name: String) {
		globalPrograms put(name, ShaderProgram new(programs get(name) id))
	}
	
	setProgram: func(model: Model, name: String) {
		program := programs get(name)
		if(program == null) {
			printf("[Scene->setProgram]: No such program '%s'\n", name)
			return
		}
		
		model setProgram(program)
	}
	
	useProgram: func(prg: ShaderProgram) {
		if(prg != null) {
			glUseProgram(prg id)
			//printf("using program #%d\n",prg program)
			glUniform1f(prg timeid,engine getTicks() as Float)
		}
	}
    
    // NOTE: is called by Model when added to the engine, shouldn't
    // be called manually
    addModel: func (model: Model) {
        mainPass models add(model)
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
			printf("[Engine]: Error, could not create shader '%s'\n", name)
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
			
			log := gc_malloc(logsize) as Char*
			glGetShaderInfoLog(shader, logsize, logsize&, log)
            
			printf("[Engine]: Error while compiling shader '%s'\n",filename)
			printf("=====================================\n")
			printf("%s\n", src)
			printf("=====================================\n")
			printf("\t%s\n", log)
			glDeleteShader(shader)
			return
		}
		
		shaders put(name, shader)
		
	}
	
	loadSrc: func(filename: String) -> Char* {
		reader := FileReader new(File new(filename))
		buffer := Buffer new()
		while(reader hasNext?()) {
			buffer append(reader read())
		}
		
		src := buffer toCString()
		src[buffer size - 1] = '\0'
		
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
	
	createProgram: func ~vertex(name, pshader, vshader: String) -> Bool {
        
		if(pshader == null && vshader == null) {
			Exception new("[Scene->addProgram]: Passed only null arguments") throw()
		}
		
		link_status := GL_TRUE
		vsh : GLuint = 0
		psh : GLuint = 0
		logsize : GLint = 0
		
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
			log := gc_malloc(logsize) as Char*
			glGetProgramInfoLog(program, logsize, logsize&, log);
			
			fprintf(stderr, "impossible de lier le program :\n%s", log)
			
			glDeleteProgram(program)
			glDeleteShader(vsh)
			glDeleteShader(psh)
			return false
		}
		
		programs put(name, ShaderProgram new(program))
		return true
	}
}
