use sdl
import sdl/[Sdl, Event]
import structs/HashMap
import Entity, Update, Message

Engine: class extends Entity {
    
    entities := HashMap<String, Entity> new()
    
    init: func ~engine{
		super("r2l_engine")
		SDL WM_GrabInput(SDL_GRAB_ON)
		addEntity(this)
		listen(KeyboardMsg, This onKey)
		printf("grabing...\n")
	}
    
    addEntity: func (entity: Entity) {
        // TODO: check for duplicates
        entities put(entity name, entity)
        entity engine = this
        entity onAdd()
    }
    
    getEntity: func (name: String) -> Entity {
        entities get(name)
    }
    
    run: func {
        while(true) {
            for(ent in entities) {
                ent update()
            }
        }
    }
    
    onKey: static func(m: KeyboardMsg) {
		this := m target
		if(m key == SDLK_q) {
			exit()
		}
	}
    
    exit: func {
		exit(0)
	}
}
