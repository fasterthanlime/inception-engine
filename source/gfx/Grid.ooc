use glew
import glew
import gfx/Quad
import engine/[Property, Types]

Grid: class extends Quad {
    
	init: func (.name) {
		super(name)	
	}
	
	render: func {
        xrange := get("x_range", Float2)
		yrange := get("y_range", Float2)
		pos := get("position", Float3)
        
        glEnable(GL_BLEND)
        glBegin(GL_LINES)

		for(y in yrange x..yrange y + 1 ) {
			glVertex3f(xrange x, y, 0)
			glVertex3f(xrange y, y, 0)
		}
		
		for(x in xrange x..xrange y + 1) {
			glVertex3f(x, yrange x, 0)
			glVertex3f(x, yrange y, 0)
		}
		
		glEnd()
		glDisable(GL_BLEND)
        
        super()
	}
    
}
