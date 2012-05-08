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
			glColor3ub(128, 128, 128)
			glVertex3d(scale x, scale y, scale z)
			glVertex3d(scale x, scale y, -scale z)
			glVertex3d(-scale x, scale y, -scale z)
			glVertex3d(-scale x, scale y, scale z)

			glColor3ub(128, 128, 128)
			glVertex3d(scale x, -scale y, scale z)
			glVertex3d(scale x, -scale y, -scale z)
			glVertex3d(scale x, scale y, -scale z)
			glVertex3d(scale x, scale y, scale z)

			glColor3ub(128, 128, 128)
			glVertex3d(-scale x, -scale y, scale z)
			glVertex3d(-scale x, -scale y, -scale z)
			glVertex3d(scale x, -scale y, -scale z)
			glVertex3d(scale x, -scale y, scale z)

			glColor3ub(128, 128, 128)
			glVertex3d(-scale x, scale y, scale z)
			glVertex3d(-scale x, scale y, -scale z)
			glVertex3d(-scale x, -scale y, -scale z)
			glVertex3d(-scale x, -scale y, scale z)

			glColor3ub(128, 128, 128)
			glVertex3d(scale x, scale y, -scale z)
			glVertex3d(scale x, -scale y, -scale z)
			glVertex3d(-scale x, -scale y, -scale z)
			glVertex3d(-scale x, scale y, -scale z)

			glColor3ub(128, 128, 128)
			glVertex3d(scale x, -scale y, scale z)
			glVertex3d(scale x, scale y, scale z)
			glVertex3d(-scale x, scale y, scale z)
			glVertex3d(-scale x, -scale y, scale z)
		glEnd()
	}
}


