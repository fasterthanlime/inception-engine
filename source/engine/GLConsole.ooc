use glew,glu,sdl,ftgl
import ftgl
import sdl/[Sdl,Event]
import glew,glu/Glu
import Entity,Property,Types,Message,EventMapper
import gfx/[RenderWindow, Model]


GLConsole: class extends Model {

	font := Ftgl new(80, 72, "data/fonts/Terminus.ttf")
	buffer := String new(128)
	inputHeight := 10
	caretStart := 0
	
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
		if(show)
			send(engine getEntity("event_mapper"),GrabKeyboard new())
		else
			send(engine getEntity("event_mapper"),UngrabKeyboard new())
	}
	
	handleKey: static func(m: KeyboardMsg) {
		if(m type != SDL_KEYDOWN)
			return
		//printf("handle key ;)")
		this := m target
		if(m key == SDLK_BACKQUOTE && m type == SDL_KEYDOWN) {
			m target as GLConsole toggleShow()
		}
		
		if(!show)
			return
			
		ch := m key as Char
		state := SDL getModState()
		// haha c'est tout moche.
		if((ch >= SDLK_SPACE && ch <= SDLK_z && ch != SDLK_LSHIFT && ch!= SDLK_RSHIFT) && !((state & KMOD_LCTRL) || (state & KMOD_RCTRL))) {
			if(state & KMOD_SHIFT) {
				ch -= (97 - 65)
			}
			//pc := (e key keysym unicode) as Char
			if(caretStart == buffer length()) {
				buffer = buffer + ch
			} else {
				buffer = buffer substring(0, caretStart) + ch + buffer substring(caretStart, buffer length())
			}
			caretStart += 1
			
		} else if(ch == SDLK_BACKSPACE && caretStart > 0) {
			buffer = buffer substring(0, caretStart - 1) + buffer substring(caretStart, buffer length())
			caretStart -= 1
			
		} else if(ch == SDLK_DELETE && caretStart < buffer length()) {
			buffer = buffer substring(0, caretStart) + buffer substring(caretStart + 1, buffer length())
			
		} else if(ch== SDLK_RIGHT && caretStart < buffer length() ) {
			caretStart += 1
			
		} else if(ch== SDLK_LEFT && caretStart > 0) {
			caretStart -= 1
			
		} else if(ch== SDLK_HOME) {
			caretStart = 0
			
		} else if(ch== SDLK_END) {
			caretStart = buffer length()
			
		}
	}
	
	bufferDraw: func {
		glPushMatrix()
		glColor3ub(255,0,0)
		glTranslated(0, 5, 0)
		font render(1, 12, 0.2, 1, buffer)
        
        // draw caret
        if(caretStart > 0) {
			bbox := font getFontBBox(caretStart)
            textWidth : Float = (bbox urx / 5)
            glTranslated(textWidth - 2, 0, 0)
        }
        font render(1, 12, 0.2, 1, "|")
        
		glPopMatrix()
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
		size := get("size",Float2)
		
		glBegin(GL_QUADS)
			glColor4ub(255, 255, 255,128)
			glVertex2i(0, 0)
			glVertex2i(size x, 0)
			glVertex2i(size x,size y)
			glVertex2i(0, size y)
		glEnd()         
	}
	
	drawText: func {
		//printf("rendering text\n")
		glColor4ub(255, 0, 0, 255)
		font render(10, 10, 0.2, true, "KALAMAZOOOO")
		bufferDraw()
	}
	
	render: func {
		if(!show)
			return
		pos := get("position",Float2)
		
		
		begin2D()
		glTranslated(pos x, pos y,0)
		background()
		glDisable(GL_BLEND)
		drawText()
		end2D()	
	}
	
	drawInputField: func {
		size := get("size",Float2)
		glPushMatrix()
		glTranslated(0,size y - inputHeight,0)
		font render(0,0,0.2, true, buffer)
		glPopMatrix()
	}
}
