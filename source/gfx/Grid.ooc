use glew
import glew
import gfx/Model
import engine/[Property,Types]

Grid: class extends Model {
	init: func ~grid(.name) {
		super(name)	
		set("x_range", Float2 new(-10, 10)) 
		set("y_range", Float2 new(-10, 10)) 
		set("position", Float3 new(0, 0, 0))
		set("color", Float3 new(1, 1, 1))
	}
	
	render: func {
		glEnable(GL_BLEND)
		xrange := get("x_range", Float2)
		yrange := get("y_range", Float2)
		pos := get("position", Float3)
		color := get("color", Float3)
		
		glTranslated(pos x, pos y, pos z)
		glColor3f(color x,color y,color z)	
		glBegin(GL_LINES)
		
		for(y in yrange x..yrange y + 1 ) {
			glVertex3f(xrange x, y,0)
			glVertex3f(xrange y, y,0)
		}
		
		for(x in xrange x..xrange y + 1) {
			glVertex3f(x, yrange x,0)
			glVertex3f(x, yrange y,0)
		}
		
		glEnd()
		
		glColor4f(color x, color y, color z, 0.5)
		glBegin(GL_QUADS)
		glVertex3f(xrange x, yrange x, 0)
		glVertex3f(xrange x, yrange y, 0)
		glVertex3f(xrange y, yrange y, 0)
		glVertex3f(xrange y, yrange x, 0)
		glEnd()
		glDisable(GL_BLEND)
	}
}
