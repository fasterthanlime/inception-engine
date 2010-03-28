use glew,sdl,glu
import glew
import glu/Glu
import sdl/Video
import engine/[Entity, Update, Engine, Types]
import gfx/[Model, RenderWindow, Camera]
import structs/LinkedList

include unistd
usleep: extern func(Int)

Scene: class extends Entity {
	
	models := LinkedList<Model> new()
	
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
}
