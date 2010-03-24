import engine/[Entity, Update]
import gfx/Model
import structs/LinkedList
Scene: class extends Entity {
	
	models := LinkedList<Model> new()
	
	render: func {
		glClearColor(0,0,0,0)
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
	    glMatrixMode(GL_MODELVIEW)
	    glLoadIdentity()
	    
	    for(model in models) {
			model render()
		}
	    
	    SDLVideo glSwapBuffers()
	}
	
	init: func ~scene(.name) {
		super(name)
		this addUpdate(Update new(render))
	}
	
	
	
	
}
