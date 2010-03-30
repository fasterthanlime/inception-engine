use glew,glu,sdl,ftgl
import ftgl
import sdl/[Sdl,Event]
import glew,glu/Glu
import Entity,Property,Types,Message,EventMapper
import gfx/[RenderWindow, Model]
import structs/LinkedList
import text/StringTokenizer

GLConsole: class extends Model {

	lines := LinkedList<String> new()  //stores all lines for displaying(you don't want messages in the history, do you)
	history := LinkedList<String> new() //only entered commands here
	
	font := Ftgl new(80, 72, "data/fonts/Terminus.ttf")
	buffer := String new(128)
	inputHeight := 10
	caretStart := 0
	
	pos := Float2 new(0,0)
	size := Float2 new(200,100)
	
	init: func ~glc (.name) {
		super(name)
		set("position",Float2 new(50,50))
		set("size",Float2 new(400,200))
		listen(KeyboardMsg,This handleKey)
		show = false
	}
	
	
	toggleShow: func {
		show = !show
		if(show) {
			send(engine getEntity("event_mapper"),GrabKeyboard new())
			send(engine getEntity("event_mapper"),GrabMouse new())
			SDL showCursor(SDL_ENABLE)
		}
		else {
			send(engine getEntity("event_mapper"),UngrabKeyboard new())
			send(engine getEntity("event_mapper"),UngrabMouse new())
			SDL showCursor(SDL_DISABLE)
		}
	}
	
	handleKey: static func(m: KeyboardMsg) {
		if(m type != SDL_KEYDOWN)
			return
		
		this := m target
		match(m key) {
			case SDLK_BACKQUOTE => {m target as GLConsole toggleShow(); return}
			case SDLK_RETURN => {m target as GLConsole command(buffer); m target as GLConsole buffer = String new(128) ; caretStart = 0}
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
		glPushMatrix()
		glTranslated(0,size y - 2 * inputHeight,0)
		bufferDraw()
		glPopMatrix()
	}
	
	render: func {
		pos = get("position",Float2)
		size = get("size", Float2)
		
		begin2D()
		glTranslated(pos x, pos y,0)
		background()
		round(10)
		glDisable(GL_BLEND)
		drawText()
		end2D()	
	}
	
	bufferDraw: func {
		glPushMatrix()
		glColor3ub(255,255,255)
		glTranslated(0, 0, 0)
		font render(1, inputHeight, 0.2, 1, buffer)
        
        // draw caret
        if(caretStart > 0) {
			bbox := font getFontBBox(caretStart)
            textWidth : Float = (bbox urx / 5)
            glTranslated(textWidth - 2, 0, 0)
        }
        font render(1, inputHeight, 0.2, 1, "|")
        
        upperpos := pos y
        posy :=pos y + size y + 5
        
         if(caretStart > 0) {
			bbox := font getFontBBox(caretStart)
            textWidth : Float = (bbox urx / 5)
            glTranslated(2 - textWidth, 0, 0)
        }
        
        for(line in lines) {
			
			posy = posy - inputHeight
			if(posy < (upperpos + inputHeight*2))
				break
				
			if(posy == posy - inputHeight)
				break
			glTranslated(0,-inputHeight,0)
			font render(1, inputHeight, 0.2, 1, line)
		}
        
		glPopMatrix()
	}
	
	command: func(cm: String) {
		history add(0,cm)
		lines add(0,cm)
		tokenizer := StringTokenizer new(cm," ")
		
		while(tokenizer hasNext()) {
			token := tokenizer nextToken()
			
			if(token == "quit")
				sendAll(QuitMessage new())
			else
				lines add(0,"unknow command: " + token)
			
			/*
			match(token) {
				case "quit" => {sendAll(QuitMessage new())}
			}
			*/
		}
	}
	
	round: func(size: Float) {
		glColor4ub(255,255,255,64)
		glPushMatrix()
		//drawing the upper left corner
		angle1 := PI
		angle2 := 3.0*PI/2.0
		step := PI/2.0/10.0
		glBegin(GL_TRIANGLE_FAN)
		glVertex2f(0,0)
		while(angle1 <= angle2) {
			glVertex2f(cos(angle1)*size,sin(angle1)*size)
			angle1 += step
		}
		glVertex2f(cos(angle2)*size,sin(angle2)*size)
		glEnd()
		
		//upper right
		glTranslated(this size x,0,0)
		angle1 = 3.0*PI/2.0
		angle2 = 4.0*PI/2.0
		glBegin(GL_TRIANGLE_FAN)
		glVertex2f(0,0)
		while(angle1 <= angle2) {
			glVertex2f(cos(angle1)*size,sin(angle1)*size)
			angle1 += step
		}
		glVertex2f(cos(angle2)*size,sin(angle2)*size)
		glEnd()
		
		//lower right
		glTranslated(0,this size y,0)
		angle1 = 0.0
		angle2 = PI/2.0
		glBegin(GL_TRIANGLE_FAN)
		glVertex2f(0,0)
		while(angle1 <= angle2) {
			glVertex2f(cos(angle1)*size,sin(angle1)*size)
			angle1 += step
		}
		glVertex2f(cos(angle2)*size,sin(angle2)*size)
		glEnd()
		
		//lower left
		glTranslated(-this size x,0,0)
		angle1 = PI/2.0
		angle2 = PI
		step = angle1/10.0
		glBegin(GL_TRIANGLE_FAN)
		glVertex2f(0,0)
		while(angle1 <= angle2) {
			glVertex2f(cos(angle1)*size,sin(angle1)*size)
			angle1 += step
		}
		glVertex2f(cos(angle2)*size,sin(angle2)*size)
		glEnd()
		
		glPopMatrix()
		
		glPushMatrix()
		glBegin(GL_QUADS)
			glVertex2f(0,0)
			glVertex2f(0 - size,0)
			glVertex2f(0 - size,0 + this size y)
			glVertex2f(0,0 + this size y)
		glEnd()
		
		glBegin(GL_QUADS)
			glVertex2f(0,0 - size)
			glVertex2f(0 + this size x,0 - size)
			glVertex2f(0 + this size x,0)
			glVertex2f(0,0)
		glEnd()
		
		glBegin(GL_QUADS)
			glVertex2f(0 + this size x,0)
			glVertex2f(0 + this size x + size,0)
			glVertex2f(0 + this size x + size,0 + this size y)
			glVertex2f(0 + this size x,0 + this size y)
		glEnd()
		
		glBegin(GL_QUADS)
			glVertex2f(0,0 + this size y)
			glVertex2f(0,0 + this size y + size)
			glVertex2f(0 + this size x,0 + this size y + size)
			glVertex2f(0 + this size x,0 + this size y)
		glEnd()
		glPopMatrix()
	}
}
