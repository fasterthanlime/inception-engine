use glew
import glew
import Model
import engine/Types
import physics/Body

include math

Line: class extends Model {
	
	begin, end: Float3
	
	init: func ~line(.name, begin := Float3 new(), end := Float3 new()) {
		super(name)
        (this begin, this end) = (begin, end)
		set("begin", begin)
		set("end", end)
	}
	
	init: func ~withmodel(.name,m1,m2: Body) {
		lineb := Float3 new(0,0,0)
		linee := Float3 new(0,0,0)
	
		m1 getPos() bind(lineb)
		m2 getPos() bind(linee)
		
		init(name,linee,lineb)
	}
	
	render: func {
		glLineWidth(6)
		glColor3f(1, 0, 0)
		glBegin(GL_LINES)
            glVertex3f(begin x, begin y, begin z)
            glVertex3f(end x, end y, end z)
		glEnd()
		glLineWidth(1)
	}


}
