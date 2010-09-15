import glew,glu/Glu
import gfx/Model
import structs/LinkedList
import Widget
import gfx/RenderWindow
import engine/Engine

Hud: class extends Model {
	
	widgets := LinkedList<Widget> new()
	
	init: func ~hud(.name) {
		super(name)
	}

	render: func {
		begin2D()
		for(widget in widgets) {
			glPushMatrix()
			widget render()
			glPopMatrix()
		}
		end2D()
	}
	
	add: func(widget: Widget) {
		widgets add(widget)
	}


	begin2D: func {
        glDisable(GL_DEPTH_TEST);
		glEnable(GL_BLEND)
        glMatrixMode(GL_PROJECTION);
        glPushMatrix();
		glLoadIdentity();
        
		rw := engine getEntity("render_window") as RenderWindow
		gluOrtho2D(0, rw width, rw height, 0);
		glMatrixMode(GL_MODELVIEW);
		glPushMatrix();
        glLoadIdentity();
	}
	
	end2D: func {
		glMatrixMode(GL_PROJECTION);
        glPopMatrix();
        glMatrixMode(GL_MODELVIEW);
        glPopMatrix();

        glEnable(GL_DEPTH_TEST);
        glDisable(GL_BLEND)
	}
	
	onAdd: func {
		engine scene getFrontPass() add(this)
	}
}
