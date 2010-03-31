use glew,glu,sdl,ftgl
import ftgl
import sdl/[Sdl,Event]
import glew,glu/Glu
import Engine,Entity,Property,Types,Message,EventMapper
import gfx/[RenderWindow, Model]
import structs/[LinkedList, HashMap]
import text/StringTokenizer

GLConsole: class extends Model {

	lines := LinkedList<String> new()  //stores all lines for displaying(you don't want messages in the history, do you)
	history := LinkedList<String> new() //only entered commands here
	commands := HashMap<String,String> new()
	//commands := LinkedList<String> new()
	
	font := Ftgl new(80, 72, "data/fonts/Terminus.ttf")
	buffer := String new(128)
	inputHeight := 12
	caretStart := 0
	
	size := Float2 new(800,600)
	
	focus := true
	alpha := 128
	
	browsingHistory := false
	iterator: LinkedListIterator<String>
	
	COMMAND := 0
	SHOW := 1
	ENT := 2
	
	init: func ~posSize (=pos, =size) {
        
		super("console")
		set("position", pos)
		set("size",     size)
		listen(KeyboardMsg, This handleKey)
		show = false
		initCommands()
        
	}
	
	initCommands: func {
		commands add("quit", "quits r2l")
		commands add("help", "help [command]")
		commands add("show", "show [entity] [...]")
	}
	
	show: func ~entity(ename: String) {
		if(ename == null) {
			cprint("usage: %s" format(commands get("show")))
			return
		}
		ent := engine getEntity(ename)
		if(ent != null) {
			cprint("%s:" format(ename))
			for(prop in ent props) {
				cprint("- %s" format(prop name))
			}
		} else {
			cprint("sorry, no such entity [%s]" format(ename))
		}
	}
	
	show: func ~entprop(ename,pname: String) {
		if(pname == null) {
			show(ename)
			return
		}
		
		ent := engine getEntity(ename)
		if(ent != null) {
			cprint("%s:" format(ename))
			for(prop in ent props) {
				cprint("- %s = %s" format(prop name, prop toString()))
			}
		} else {
			cprint("sorry, no such entity [%s]" format(ename))
		}
	}
	
	quit: func {
		sendAll(QuitMessage new())
	}
	
	help: func(cm: String) {
		if(cm == null) {
			cprint("usage: help [command]")
		} else {
			hlpStr := commands get(cm)
			if(hlpStr != null) {
				cprint("%s: %s" format(cm,hlpStr))
			} else {
				cprint("unknown command: %s" format(cm))
			}
		}
	}
	
	toggleShow: func {
		show = !show
		if(show) {
			block()
			
			focus = true
		}
		else {
			unblock()
			
			focus = false
		}
	}
	
	toggleFocus: func {
		focus = !focus
		if(focus) {
			alpha = 128
			block()
		} else {
			alpha = 64
			unblock()
		}
	}
	
	block: func {
		send(engine getEntity("event_mapper"),GrabKeyboard new())
		send(engine getEntity("event_mapper"),GrabMouse new())
		SDL showCursor(SDL_ENABLE)
	}
	
	unblock: func {
		send(engine getEntity("event_mapper"),UngrabKeyboard new())
		send(engine getEntity("event_mapper"),UngrabMouse new())
		SDL showCursor(SDL_DISABLE)
	}
	
	handleKey: static func(m: KeyboardMsg) {
		this := m target
		state := SDL getModState()
		
		if(m type != SDL_KEYDOWN)
			return
		
		if(m key == SDLK_BACKQUOTE && !(state & KMOD_LCTRL)) {
			toggleShow()
			browsingHistory = false
			return
		} else if(m key == SDLK_BACKQUOTE) {
			toggleFocus()
		}
		
		if(!show || !focus)
			return
		
		match(m key) {
			case SDLK_RETURN => {
				command(buffer)
				buffer = String new(128)
				caretStart = 0
				browsingHistory = false
			}
			
			case SDLK_UP => {
				if(!browsingHistory) {
					iterator = history iterator()
					browsingHistory = true
				}
				
				if(iterator hasNext()) {
					setBuffer(iterator next() clone())
				}
			}
			
			case SDLK_DOWN => {
				if(!browsingHistory) {
					iterator = history iterator()
					browsingHistory = true
				}
				
				if(iterator hasPrev()) {
					setBuffer(iterator prev() clone())
				} else {
					buffer = String new(128)
					browsingHistory = false
				}
			}
			
			case SDLK_TAB => {
				completion(buffer clone())
			}
			
			case SDLK_l => {
				if(state & KMOD_LCTRL)
					lines clear()
			}
		} 
		
		
			
		ch := m key as Char
		
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
	
	setBuffer: func(text: String) {
		buffer = text clone()
		caretStart = buffer length()
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
	
	completion: func(begin: String) {
		suggs := LinkedList<String> new()
		tokenizer := StringTokenizer new(begin, " ")
		correctTokens := LinkedList<String> new()
		status := COMMAND
		
		
		
		
		level := 0
		for(token in tokenizer) {
			match(level) {
				case 0 => {
					suggs clear()
					if(commands get(token) == null) {
						for(key in commands getKeys()) {
							if(key startsWith(token)) {
								suggs add(key)
							}
						}
						break
					} else {
						correctTokens add(token clone())
					}
				}
				
				case 1 => {
					suggs clear()
					if(correctTokens last() == "show") {
						status = SHOW
						ent := engine getEntity(token)
						if(ent == null) {
							for(key in engine entities getKeys()) {
								if(key startsWith(token)) {
									suggs add(key)
								}
							}
							break
						} else {
							correctTokens add(token clone())
						}
					}
				}
				
				case 2 => {
					match(status) {
						case SHOW => {
							status = ENT
							suggs clear()
							ent := engine getEntity(correctTokens last())
							prop := ent props get(token)
							if(prop == null) {
								for(key in ent props getKeys()) {
									if(key startsWith(token)) {
										suggs add(key)
									}
								}
								break
							} else {
								correctTokens add(token clone())
							}
						}
					}
				}
			}
			level += 1
		}
		
		correctToken := ""
		for(token in correctTokens) {
			correctToken += token
			correctToken += " "
		}
		
		if(begin == "") {
			for(key in commands getKeys()) {
				if(key startsWith("")) {
					suggs add(key)
				}
			}
		}
		
		if(suggs size() > 1) {
			if(correctToken == "") {
				cprint("avalaible commands:")
			} else {
				cprint("%s →" format(buffer))
			}
			for(sugg in suggs) {
				cprint(" • %s" format(sugg))
			}
		} else if(suggs size() == 1) {
			setBuffer("%s%s " format(correctToken,suggs[0]))
		} else {
			match(status) {
				case COMMAND => cprint("Sorry, no command begins with '%s'" format(correctTokens last()))
				case SHOW => cprint("Sorry, no entity begins with '%s'" format(correctTokens last()))
				case ENT => cprint("Sorry, no property begins with '%s'" format(correctTokens last()))
			}
		}
			
	}
	
	cprint: func(line: String) {
		lines add(0,line)
		if(lines size > 100)
			lines removeLast()
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
			glColor4ub(255, 255, 255,alpha)
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
		pos = get("position",Float3)
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
        posy := pos y + size y + 5
        
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
	
	breakLine: func(_line: String) -> LinkedList<String> {
		elems := LinkedList<String> new()
		lastSpace := 0
		elemStart := 0
		line := _line clone()
		
		
		for(i in 0..line length()) {
			bbox := font getFontBBox(i - elemStart)
			textWidth : Float = (bbox urx / 5)
			if(textWidth > (size x - 50)) {
				//line split()
			}
			if(line[i] == ' ')
				lastSpace = i
		}
		return elems
	}
	
	command: func(cm: String) {
		if(cm == "") {
			cprint(String new(20))
			return
		}
		history add(0,cm)
		lines add(0,cm)
		tokenizer := StringTokenizer new(cm," ")
		
		
		token := tokenizer nextToken()
		if(token == "quit") {
			quit()
		} else if(token == "help"){
			arg1 := tokenizer nextToken()
			help(arg1)
		} else if(token == "show") {
			arg1 := tokenizer nextToken()
			arg2 := tokenizer nextToken()
			show(arg1,arg2)
		} else {
			cprint("unknown command: " + token)
		}
		
		/*
		match(token) {
			case "quit" => {sendAll(QuitMessage new())}
		}
		*/
		
	}
	
	round: func(size: Float) {
		glColor4ub(255,255,255,alpha)
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
