use glew
import glew
import gfx/Model
import engine/Types

Cube: class extends Model {
    
	init: func ~cube(.name) {
		super(name)
        set("scale", Float3 new(1, 1, 1))
	}
	
	render: func {
        scale := get("scale", Float3)
        
		glBegin(GL_QUADS)
			glColor3ub(255, 0, 0) //face rouge
			glVertex3d(scale x, scale y, scale z)
			glVertex3d(scale x, scale y, -scale z)
			glVertex3d(-scale x, scale y, -scale z)
			glVertex3d(-scale x, scale y, scale z)

			glColor3ub(0, 255, 0) //face verte
			glVertex3d(scale x, -scale y, scale z)
			glVertex3d(scale x, -scale y, -scale z)
			glVertex3d(scale x, scale y, -scale z)
			glVertex3d(scale x, scale y, scale z)

			glColor3ub(0, 0, 255) //face bleue
			glVertex3d(-scale x, -scale y, scale z)
			glVertex3d(-scale x, -scale y, -scale z)
			glVertex3d(scale x, -scale y, -scale z)
			glVertex3d(scale x, -scale y, scale z)

			glColor3ub(255, 255, 0) //face jaune
			glVertex3d(-scale x, scale y, scale z)
			glVertex3d(-scale x, scale y, -scale z)
			glVertex3d(-scale x, -scale y, -scale z)
			glVertex3d(-scale x, -scale y, scale z)

			glColor3ub(0, 255, 255) //face cyan
			glVertex3d(scale x, scale y, -scale z)
			glVertex3d(scale x, -scale y, -scale z)
			glVertex3d(-scale x, -scale y, -scale z)
			glVertex3d(-scale x, scale y, -scale z)

			glColor3ub(255, 0, 255) //face magenta
			glVertex3d(scale x, -scale y, scale z)
			glVertex3d(scale x, scale y, scale z)
			glVertex3d(-scale x, scale y, scale z)
			glVertex3d(-scale x, -scale y, scale z)
		glEnd()
	}


}
