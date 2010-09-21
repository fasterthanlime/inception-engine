use glew
import glew
import gfx/Model, gfx/gl/GLPrimitives
import engine/[Property, Types]

Quad: class extends Model {
    
	init: func (.name) {
		super(name)	
		set("x_range", Float2 new(-10, 10))
		set("y_range", Float2 new(-10, 10))
		set("position", Float3 new(0, 0, 0))
		//set("color", Float3 new(1, 1, 1)
        set("color", Float3 new(0.5, 0.5, 0.5))
	}

    render: func {
		xrange := get("x_range", Float2)
		yrange := get("y_range", Float2)
		pos := get("position", Float3)
		color := get("color", Float3)

        //glColor3f(color x, color y, color z)
		glXYQuad(xrange x, xrange y, yrange x, yrange y)
	}
    
}
