use glew
import glew
import gfx/Model
import engine/[Property, Types]

Quad: class extends Model {
    
	init: func (.name) {
		super(name)	
		set("x_range", Float2 new(-10, 10))
		set("y_range", Float2 new(-10, 10))
		set("position", Float3 new(0, 0, 0))
		set("color", Float3 new(1, 1, 1))
	}
	
	render: func {
		xrange := get("x_range", Float2)
		yrange := get("y_range", Float2)
		pos := get("position", Float3)
		color := get("color", Float3)

        glEnable(GL_BLEND)
		glColor3f(color x, color y, color z)
		glBegin(GL_QUADS)
            glTexCoord2f(0, 0)
            glVertex3f(xrange x, yrange x, 0)
            glTexCoord2f(0, 1)
            glVertex3f(xrange x, yrange y, 0)
            glTexCoord2f(1, 1)
            glVertex3f(xrange y, yrange y, 0)
            glTexCoord2f(1, 0)
            glVertex3f(xrange y, yrange x, 0)
		glEnd()
		glDisable(GL_BLEND)
	}
    
}
