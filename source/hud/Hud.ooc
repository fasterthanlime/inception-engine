import glew,glu/Glu
import gfx/Model
import structs/LinkedList
import Window
import gfx/RenderWindow

Hud: class extends Model {
	
	windows := LinkedList<Window> new()
	
	init: func ~hud(.name) {
		super(name)
	}

	render: func {
		begin2D()
		for(window in windows) {
			glPushMatrix()
			window render()
			glPopMatrix()
		}
		end2D()
	}
	
	add: func(win: Window) {
		if(win == null) {
			printf("[Hud]: Trying to add a null window\n")
			return
		}
		windows add(win)
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
}
