use sdl
import sdl/[Core, Event]
import Message
import engine/[Entity, Message]

EventMapper: class extends Entity {
    
	event: Event
    keyGrabber = null, mouseGrabber = null : Entity
	
	init: func ~em {
		super("event_mapper")
        
        listen(GrabKeyboard, func (m: Message) {
            this := m target
            keyGrabber = m sender
        })
        
        listen(UngrabKeyboard, func (m: Message) {
            this := m target
            if(keyGrabber == m sender) {
                // only the original grabber can ungrab =)
                keyGrabber = null
            }
        })
        
        listen(GrabMouse, func (m: Message) {
            this := m target
            mouseGrabber = m sender
        })
        
        listen(UngrabMouse, func (m: Message) {
            this := m target
            if(mouseGrabber == m sender) {
                // only the original grabber can ungrab =)
                mouseGrabber = null
            }
        })
	}
	
	update: func {
		super()
		
		while(SDLEvent poll(event&)) {
            if(event type == SDL_QUIT) {
                sendAll(QuitMessage new())
			} else if(event type == SDL_KEYUP || event type == SDL_KEYDOWN) {
                msg := KeyboardMsg new(event key keysym sym, event key keysym unicode, event type)
                if(keyGrabber) {
                    send(keyGrabber, msg)
                } else {
                    sendAll(msg)
                }
			} else if(event type == SDL_MOUSEMOTION) {
                msg := MouseMotion new (
					event motion x,   event motion y,
					event motion xrel,event motion yrel
                )
                if(mouseGrabber) {
                    send(mouseGrabber, msg)
                } else {
                    sendAll(msg)
                }
			} else if(event type == SDL_MOUSEBUTTONUP || event type == SDL_MOUSEBUTTONDOWN) {
				sendAll(MouseButton new(event button button, event type, event motion x, event motion y))
			} else if(event type == SDL_VIDEORESIZE) {
				sendAll(ResizeEvent new(event resize w, event resize h))
			}
		}
	}
}

GrabKeyboard:   class extends Message {}
GrabMouse:      class extends Message {}
UngrabKeyboard: class extends Message {}
UngrabMouse:    class extends Message {}
