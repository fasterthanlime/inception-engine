use sdl, glew

import glew
import sdl/[Core, Event]
import structs/HashMap
import Entity, Update, Message, Types
import io/File
import gfx/Scene
import hud/Hud

Engine: class extends Entity {
    
    entities := HashMap<String, Entity> new()
    
    scene := Scene new("default_scene")
	hud := Hud new("default_hud")
	
    time1, time2, dt: UInt32 = 0
	time: UInt32 = 0
    
    init: func ~engine {
		super("r2l_engine")
		addEntity(this)
		listen(KeyboardMsg, This onKey)
		addEntity(scene)
		addEntity(hud)
		set("scene", scene)
		set("hud", hud)
	}
    
    addEntity: func (entity: Entity) {
        name := entity name
        seed := 2
        evilBro := entities get(name)
        while(evilBro) {
            name = "%s__%d" format(entity name, seed)
            seed += 1
            evilBro = entities get(name)
        }
        
        entity name = name
        entities put(name, entity)
        entity engine = this
        entity onAdd()
    }
    
    removeEntity: func (entity: Entity) {
        entity onRemove()
        entities remove(entity getName())
    }
	
	getHud: func -> Hud {
		return hud
	}
    
    getEntity: func (name: String) -> Entity {
        return entities get(name)
    }
    
    getEntity: func ~over <T> (name: String, T: Class) -> T {
		ent := entities get(name)
		if(!ent class inheritsFrom?(T)) {
            Exception new(This, "Attempting to get (%s, %s), but the entity has incompatible type %s" format(name, T name, ent class name)) throw()
        }
        return ent
	}
    
    run: func {
        while(true) {
			time1 = time2
            for(ent in entities) {
                ent update()
            }
            time2 = SDL getTicks()
			time = time2
            dt = time2 - time1
        }
    }
	
	getTicks: func -> UInt32 {
		return time
	}
    
    onKey: static func(m: KeyboardMsg) {
		this := m target
	}
    
    exit: func {
		exit(0)
	}

}
