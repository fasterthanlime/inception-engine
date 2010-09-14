use glew
import glew
import gfx/Model

Cube: class extends Model {
    
	init: func ~cube(.name) {
		super(name)
        set("side", 1.0)
	}
	
	render: func {
        side := get("side", Float)
        
		glBegin(GL_QUADS)
			glColor3ub(255, 0, 0) //face rouge
			glVertex3d(side, side, side)
			glVertex3d(side, side, -side)
			glVertex3d(-side, side, -side)
			glVertex3d(-side, side, side)

			glColor3ub(0, 255, 0) //face verte
			glVertex3d(side, -side, side)
			glVertex3d(side, -side, -side)
			glVertex3d(side, side, -side)
			glVertex3d(side, side, side)

			glColor3ub(0, 0, 255) //face bleue
			glVertex3d(-side, -side, side)
			glVertex3d(-side, -side, -side)
			glVertex3d(side, -side, -side)
			glVertex3d(side, -side, side)

			glColor3ub(255, 255, 0) //face jaune
			glVertex3d(-side, side, side)
			glVertex3d(-side, side, -side)
			glVertex3d(-side, -side, -side)
			glVertex3d(-side, -side, side)

			glColor3ub(0, 255, 255) //face cyan
			glVertex3d(side, side, -side)
			glVertex3d(side, -side, -side)
			glVertex3d(-side, -side, -side)
			glVertex3d(-side, side, -side)

			glColor3ub(255, 0, 255) //face magenta
			glVertex3d(side, -side, side)
			glVertex3d(side, side, side)
			glVertex3d(-side, side, side)
			glVertex3d(-side, -side, side)
		glEnd()
	}


}
