use glew, glu, sdl, ftgl
import ftgl
import sdl/[Core,Event]
import glew,glu/Glu
import engine/[Engine, Entity, Property, Types, Message, EventMapper]
import gfx/[RenderWindow, Model]

import structs/[LinkedList, HashMap]
import text/StringTokenizer
import io/FileReader

import hud/Window
import Command

Console: class extends Window {

	lines := LinkedList<String> new()  //stores all lines for displaying(you don't want messages in the history, do you)
	history := LinkedList<String> new() //only entered commands here
	commands := HashMap<String, Command> new()
	
	font := Ftgl new(80, 72, "data/fonts/Terminus.ttf")
	buffer := Buffer new(128) toString()
	inputHeight := 12
	caretStart := 0
	
	printedLine := true
	
	show = false
	
	browsingHistory := false
	iterator: LinkedListIterator<String>
	
	COMMAND = 0, SHOW = 1, ENT = 2 : Int
	
	init: func ~consoleinit (x, y, width, height: Float) {
		super("console", x, y, width, height)
		show = false
		listen(KeyboardMsg, This handleKey)
		initCommands()
	}
	
	wRender: func {
		drawText()
	}
	
	load: func (fileName: String) {
		fR := FileReader new(fileName)
		while(fR hasNext?()) {
			line := fR readLine() trim()
			if(!line empty?()) command(line)
		}
		fR close()
	}
	
	initCommands: func {
		addCommand(Command new("show", "show [entity] [...]", func (console: Console, st: StringTokenizer) {
            ename := st nextToken()
            if(!ename) {
				command("help show"); return
			}
            
            pname := st nextToken()
            
            ent := console engine getEntity(ename)
            if(ent == null) {
                console cprintln("sorry, no such entity [%s]" format(ename toCString()))
                return
            }
                
            // display a particular property
            if(pname != null && !pname empty?()) {
                prop := ent props get(pname)
                if(prop == null) {
                    console cprintln("sorry, entity [%s] doesn't have a property named [%s]" format(ename toCString(), pname toCString()))
                    return
                }
                console cprintln(prop toString())
                return
            }
            
            // display all properties
            console cprintln("%s:" format(ename toCString()))
            for(prop in ent props) {
                console cprintln("- %s = %s" format(prop name toCString(), prop toString() toCString()))
            }
        }))
        
        addCommand(Command new("set", "set entity property value", func (console: Console, st: StringTokenizer) {
			ename := st nextToken()
			if(!ename) command("help set")
			
			pname := st nextToken()
			if(!pname) command("help set")
			
			ent := console engine getEntity(ename)
            if(ent == null) {
                console cprintln("sorry, no such entity [%s]" format(ename toCString()))
                return
            }
                
            // display a particular property
            if(pname != null && !pname empty?()) {
                prop := ent props get(pname)
                if(prop == null) {
                    console cprintln("sorry, entity [%s] doesn't have a property named [%s]" format(ename toCString(), pname toCString()))
                    return
                }
                msg := prop fromString(st)
                if(!msg empty?()) msg println()
            }
		}))
        
		addCommand(Command new("help", "help [command]", func (console: Console, st: StringTokenizer) {
            name := st nextToken()
            
            if(name == null) {
                console cprintln("usage: help [command]")
            } else {
                command := console commands get(name)
                if(command != null) {
                    console cprintln("%s: %s" format(name toCString(), command getHelp() toCString()))
                } else {
                    console cprintln("unknown command: %s" format(name toCString()))
                }
            }
        }))
        
		addCommand(Command new("quit", "quits r2l", func (console: Console, st: StringTokenizer) {
            console sendAll(QuitMessage new())
        }))
	}
    
    addCommand: func (c: Command) {
        commands put(c getName(), c)
        c console = this
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
				buffer = Buffer new(128) toString()
				caretStart = 0
				browsingHistory = false
			}
			
			case SDLK_UP => {
				if(!browsingHistory) {
					iterator = history iterator()
					browsingHistory = true
				}
				
				if(iterator hasNext?()) {
					setBuffer(iterator next() clone())
				}
			}
			
			case SDLK_DOWN => {
				if(!browsingHistory) {
					iterator = history iterator()
					browsingHistory = true
				}
				
				if(iterator hasPrev?()) {
					setBuffer(iterator prev() clone())
				} else {
					buffer = Buffer new(128) toString()
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
		
		ch := (m unicode & 0x7f) as Char
		
		if(m key == SDLK_BACKSPACE && caretStart > 0) {
			buffer = buffer substring(0, caretStart - 1) + buffer substring(caretStart, buffer length())
			caretStart -= 1
			
		} else if(m key == SDLK_DELETE && caretStart < buffer length()) {
			buffer = buffer substring(0, caretStart) + buffer substring(caretStart + 1, buffer length())
			
		} else if(m key == SDLK_RIGHT && caretStart < buffer length() ) {
			caretStart += 1
			
		} else if(m key == SDLK_LEFT && caretStart > 0) {
			caretStart -= 1
			
		} else if(m key == SDLK_HOME) {
			caretStart = 0
			
		} else if(m key== SDLK_END) {
			caretStart = buffer length()
			
		} else if(ch printable?() && !(state & KMOD_LCTRL) && !(state & KMOD_RCTRL)) {
			if(caretStart == buffer length()) {
				buffer = buffer + ch
			} else {
				buffer = buffer substring(0, caretStart) + ch + buffer substring(caretStart, buffer length())
			}
			caretStart += 1
		}
	}
	
	setBuffer: func(text: String) {
		buffer = text clone()
		caretStart = buffer length()
	}
	
	completion: func(begin: String) {
		suggs := LinkedList<String> new()
		tokenizer := StringTokenizer new(begin, " ")
		correctTokens := LinkedList<String> new()
		status := COMMAND
		
		level := 0
		for(token in tokenizer) {
			if(token trim() empty?()) break
			
			match(level) {
				case 0 => {
					suggs clear()
					if(commands get(token) == null) {
						for(key in commands getKeys()) {
							if(key startsWith?(token)) {
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
						if(ent) {
							correctTokens add(token clone())
						} else {
							for(key in engine entities getKeys()) {
								if(key startsWith?(token)) {
									suggs add(key)
								}
							}
							break
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
									if(key startsWith?(token)) {
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
				if(key startsWith?("")) {
					suggs add(key)
				}
			}
		}
		
		if(suggs size > 1) {
			if(correctToken == "") {
				cprintln("available commands:")
			} else {
				cprintln("%s ->" format(buffer toCString()))
			}
			for(sugg in suggs) {
				cprintln(" * %s" format(sugg toCString()))
			}
            
            limit := 9999999
            for(sugg in suggs) {
                len := sugg length()
                if(limit > len) {
                    limit = len
                }
            }
            
            finished := false
            best := 0
            while(best < limit) {
                for(sugg1 in suggs) {
                    for(sugg2 in suggs) {
                        if(sugg1 as Pointer == sugg2 as Pointer) continue
                        if(sugg1[best] != sugg2[best]) {
                            finished = true
                            break
                        }
                    }
                    if (finished) break
                }
                if (finished) break
                best += 1
            }
            setBuffer(correctToken + suggs[0] substring(0, best))
            
		} else if(suggs size == 1) {
			setBuffer(correctToken + suggs[0])
		} else {
			match(status) {
				case COMMAND => cprintln("Sorry, no command begins with '%s'"  format(buffer toCString()))
				case SHOW    => cprintln("Sorry, no entity begins with '%s'"   format(correctTokens last() toCString()))
				case ENT     => cprintln("Sorry, no property begins with '%s'" format(correctTokens last() toCString()))
			}
		}
			
	}
	
	cprint: func(line: String) {
		firstLine: String = null
		if(lines size > 0)
			firstLine = lines get(0)
		
		if(firstLine != null) {
			lines set(0, firstLine + line)
		} else {
			lines add(0, "")
			lines set(0, line)
		}
			
		printedLine = false
	}
	
	cprintln: func ~withcontent(line: String) {
		if(!printedLine) {
			first := lines get(0)
			if(first != null) {
				lines set(0, first + line)
			} else {
				lines add(0, line)
				printedLine = true
			}	
		} else {
			lines add(0, line)
			printedLine = true
		}
		
		if(lines size > 100)
			lines removeLast()
	}
	
	cprintln: func ~empty {
		if(printedLine) {
			lines add(0,"")
		}
		printedLine = true
		if(lines size > 100)
			lines removeLast()
	}
	
	
	drawText: func {
		size := get("size", Float2)

        glPushMatrix()
		glTranslated(0, size y - 2 * inputHeight, 0)
		bufferDraw()
		glPopMatrix()
	}
	
	bufferDraw: func {
		pos  := get("position", Float3)
		size := get("size", Float2)
		glPushMatrix()
		glColor3ub(255,255,255)
		glTranslated(0, 0, 0)
		font render(1, inputHeight, 0.2, true, buffer)
        
        // draw caret
        if(caretStart > 0) {
			bbox := font getFontBBox(caretStart)
            textWidth : Float = (bbox urx / 5)
            glTranslated(textWidth - 2, 0, 0)
        }
        font render(1, inputHeight, 0.2, true, "|")
        
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
			font render(1, inputHeight, 0.2, true, line)
		}
        
		glPopMatrix()
	}
	
	breakLine: func(_line: String) -> LinkedList<String> {
		elems := LinkedList<String> new()
		lastSpace := 0
		elemStart := 0
		line := _line clone()
		size := get("size", Float2)
		
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
            cprintln("")
			return
		}
        
		history add(0, cm)
		lines add(0, cm)
		tokenizer := StringTokenizer new(cm, " ")
		
		token := tokenizer nextToken()
        command := commands get(token)
        if(command == null) {
            cprintln("Unknown command: " + token)
        } else {
            command action(this, tokenizer)
		}
		
		/*
		match(token) {
			case "quit" => { sendAll(QuitMessage new()) }
		}
		*/
		
	}
	
}
