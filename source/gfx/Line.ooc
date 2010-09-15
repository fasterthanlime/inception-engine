use glew
import glew
import Model
import engine/Types
import physics/Body
import gfx/gl/GLPrimitives

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
		lineb := Float3 new()
		linee := Float3 new()
	
		m1 getPos() bind(lineb)
		m2 getPos() bind(linee)
		
		init(name,linee,lineb)
	}
	
	render: func {
        begin = get("begin", Float3)
        end   = get("end",   Float3)
        
		glColor3f(1, 0, 0)
        glLine(begin x, end x, begin y, end y, begin z, end z)
	}


}
