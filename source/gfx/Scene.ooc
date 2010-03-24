use glew,sdl,glu
import glew
import glu/Glu
import sdl/Video
import engine/[Entity, Update]
import gfx/Model
import structs/LinkedList

Scene: class extends Entity {
	
	models := LinkedList<Model> new()
	
	render: func -> Bool {
		glClearColor(0,0,0,0)
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
	    glMatrixMode(GL_MODELVIEW)
	    glLoadIdentity()
	    gluLookAt(6,6,6,
				  0,0,0,
				  0,0,1)
	    
	    for(model in models) {
			model render()
		}
	    
	    SDLVideo glSwapBuffers()
	    return true
	}
	
	init: func ~scene(.name) {
		super(name)
		this addUpdate(Update new(This render))
	}
}
