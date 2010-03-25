use glew,glu
import glew,glu/Glu
import Entity,Property,Types
import gfx/RenderWindow


GLConsole: class extends Entity {
	//font := Ftgl new(80,72,"font/Terminus.ttf")
	init: func ~glc (.name) {
		super(name)
		set("position",Float2 new(0,0))
		set("size",Float2 new(200,100))
	}
	
	update: func {
		super()
		 glDisable(GL_DEPTH_TEST);
		 glEnable(GL_BLEND)

        glMatrixMode(GL_PROJECTION);
        glPushMatrix();
            glLoadIdentity();
            rw := engine getEntity("render_window") as RenderWindow
            gluOrtho2D(0, rw width, 0, rw height);
            glMatrixMode(GL_MODELVIEW);
            glPushMatrix();
                glLoadIdentity();

                glBegin(GL_QUADS);
                    glColor4ub(175, 175, 85,128);
                    glVertex2i(  0, -50);
                    glVertex2i(  0,  50);
                    glVertex2i(100,  50);
                    glVertex2i(100, -50);
                glEnd();

                glMatrixMode(GL_PROJECTION);
            glPopMatrix();
            glMatrixMode(GL_MODELVIEW);
        glPopMatrix();

        glEnable(GL_DEPTH_TEST);
        glDisable(GL_BLEND)
	}
}
