use glew, glu, ftgl
import glew, glu/Glu, ftgl
import Entity,Property,Types
import gfx/[RenderWindow, Model]


GLConsole: class extends Model {
	font := Ftgl new(80, 72, "data/fonts/Terminus.ttf")
	init: func ~glc (.name) {
		//super(name)
		this name = name
		set("position",Float2 new(0,0))
		set("size",Float2 new(200,100))
	}
	
	render: func {
		 glDisable(GL_DEPTH_TEST);
		// glEnable(GL_BLEND)

        glMatrixMode(GL_PROJECTION);
        glPushMatrix();
            glLoadIdentity();
            rw := engine getEntity("render_window") as RenderWindow
            pos := get("position",Float2)
            size := get("size",Float2)
           /* gluOrtho2D(0, rw width, rw height, 0);
            glMatrixMode(GL_MODELVIEW);
            glPushMatrix();
                glLoadIdentity();

                glBegin(GL_QUADS);
                    glColor4ub(255, 255, 255,255);
                    glVertex2i(pos x, pos y);
                    glVertex2i(pos x + size x, pos y);
                    glVertex2i(pos x + size x, pos y + size y);
                    glVertex2i(pos x, pos y + size y);
                glEnd();

                glMatrixMode(GL_PROJECTION);
            glPopMatrix();
            glMatrixMode(GL_MODELVIEW);
        glPopMatrix();

        glEnable(GL_DEPTH_TEST);
        glDisable(GL_BLEND)*/
        
        
        glMatrixMode(GL_PROJECTION);
	    glPushMatrix();
	    glLoadIdentity();
	    gluOrtho2D(0, rw width, rw height, 0);
	    glMatrixMode(GL_MODELVIEW);
	 
				glBegin(GL_QUADS);
                    glColor4ub(255, 255, 255,255);
                    glVertex2i(pos x, pos y);
                    glVertex2i(pos x + size x, pos y);
                    glVertex2i(pos x + size x, pos y + size y);
                    glVertex2i(pos x, pos y + size y);
                glEnd();
	 
	    glMatrixMode(GL_PROJECTION);
	    glPopMatrix();
	    glMatrixMode(GL_MODELVIEW);
	}
}
