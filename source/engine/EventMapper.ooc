use sdl
import sdl/[Sdl,Event]
import Message
import engine/[Entity, QuitMessage, Message]

EventMapper: class extends Entity {
	event: Event
	
	init: func ~em {
		super("event_mapper")
	}
	
	init: func ~emname (.name) {
		super(name)
	}
	
	update: func {
		super()
		
		while(SDLEvent poll(event&)) {
			if(event type == SDL_QUIT) {
				sendAll(QuitMessage new())
			} else if(event type == SDL_KEYUP) {
				printf("keyuuuuuuuuuuuup\n")
				sendAll(KeyboardMsg new(event key keysym sym))
			
			} else if(event type == SDL_MOUSEMOTION) {
				sendAll(MouseMotion new (
					event motion x, event motion y,
					event motion xrel,event motion yrel)
						)
			}
		}
	}
}
