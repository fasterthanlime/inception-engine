use glew
import glew
import gfx/Model

Cube: class extends Model {
	init: func ~cube(.name) {
		super(name)
	}
	
	
	
	render: func {
		printf("rendering cube =)\n")
		glBegin(GL_QUADS)
			glColor3ub(255,0,0) //face rouge
			glVertex3d(1,1,1)
			glVertex3d(1,1,-1)
			glVertex3d(-1,1,-1)
			glVertex3d(-1,1,1)

			glColor3ub(0,255,0) //face verte
			glVertex3d(1,-1,1)
			glVertex3d(1,-1,-1)
			glVertex3d(1,1,-1)
			glVertex3d(1,1,1)

			glColor3ub(0,0,255) //face bleue
			glVertex3d(-1,-1,1)
			glVertex3d(-1,-1,-1)
			glVertex3d(1,-1,-1)
			glVertex3d(1,-1,1)

			glColor3ub(255,255,0) //face jaune
			glVertex3d(-1,1,1)
			glVertex3d(-1,1,-1)
			glVertex3d(-1,-1,-1)
			glVertex3d(-1,-1,1)

			glColor3ub(0,255,255) //face cyan
			glVertex3d(1,1,-1)
			glVertex3d(1,-1,-1)
			glVertex3d(-1,-1,-1)
			glVertex3d(-1,1,-1)

			glColor3ub(255,0,255) //face magenta
			glVertex3d(1,-1,1)
			glVertex3d(1,1,1)
			glVertex3d(-1,1,1)
			glVertex3d(-1,-1,1)
		glEnd()
	}


}
