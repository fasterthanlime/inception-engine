use sdl
import sdl/[Sdl, Event]
import structs/HashMap
import Entity, Update, Message

Engine: class extends Entity {
    
    entities := HashMap<String, Entity> new()
    
    init: func ~engine{
		super("r2l_engine")
		addEntity(this)
		listen(KeyboardMsg, This onKey)
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
        // Disabled for debugging
		SDL WM_GrabInput(SDL_GRAB_ON)
		SDL showCursor(SDL_DISABLE)
        while(true) {
            for(ent in entities) {
                ent update()
            }
        }
    }
    
    onKey: static func(m: KeyboardMsg) {
		this := m target
	}
    
    exit: func {
		exit(0)
	}
}
