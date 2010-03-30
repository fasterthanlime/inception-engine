use sdl,glew
import glew
import sdl/[Sdl, Event]
import structs/HashMap
import Entity, Update, Message
import io/File
import gfx/Scene

Engine: class extends Entity {
    
    entities := HashMap<String, Entity> new()
    scene := Scene new("default_scene")
    time1: UInt32 = 0
    time2: UInt32 = 0
	dt: UInt32 = 0
    
    init: func ~engine{
		super("r2l_engine")
		addEntity(this)
		listen(KeyboardMsg, This onKey)
		addEntity(scene)
		set("scene", scene)
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
        while(true) {
			time1 = time2
            for(ent in entities) {
                ent update()
            }
            time2 = SDL getTicks()
            dt = time2 - time1
        }
    }
    
    onKey: static func(m: KeyboardMsg) {
		this := m target
	}
    
    exit: func {
		exit(0)
	}
}
