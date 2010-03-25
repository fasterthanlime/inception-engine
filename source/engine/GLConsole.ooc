use glew,glu,sdl,ftgl
import ftgl
import sdl/[Sdl,Event]
import glew,glu/Glu
import Entity,Property,Types,Message
import gfx/[RenderWindow, Model]


GLConsole: class extends Model {
	font := Ftgl new(80,72,"font/Terminus.ttf")
	init: func ~glc (.name) {
		//super(name)
		this name = name
		set("position",Float2 new(50,50))
		set("size",Float2 new(400,200))
		listen(KeyboardMsg,This handleKey)
	}
	
	show := false
	
	toggleShow: func {
		show = !show
	}
	
	handleKey: static func(m: KeyboardMsg) {
		printf("handle key ;)")
		if(m key == SDLK_BACKQUOTE)
			m target as GLConsole toggleShow()
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
	
	background: func {
		pos := get("position",Float2)
		size := get("size",Float2)
		
		glBegin(GL_QUADS)
			glColor4ub(255, 255, 255,128)
			glVertex2i(pos x, pos y)
			glVertex2i(pos x + size x, pos y)
			glVertex2i(pos x + size x, pos y + size y)
			glVertex2i(pos x, pos y + size y)
		glEnd()         
	}
	
	drawText: func {
		font render(0,0,1,true,"KALAMAZOOOO")
	}
	
	render: func {
		if(!show)
			return
		
		begin2D()
		background()
		drawText()
		end2D()	
	}
}
