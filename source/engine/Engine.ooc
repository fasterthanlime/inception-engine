use sdl, glew
import glew
import sdl/[Sdl, Event]
import structs/HashMap
import Entity, Update, Message, Types
import io/File
import gfx/Scene

Engine: class extends Entity {
    
    entities := HashMap<String, Entity> new()
    
    scene := Scene new("default_scene")
    time1, time2, dt: UInt32 = 0
	time: UInt32 = 0
    
    init: func ~engine{
		super("r2l_engine")
		addEntity(this)
		listen(KeyboardMsg, This onKey)
		addEntity(scene)
		set("scene", scene)
	}
    
    addEntity: func (entity: Entity) {
        name := entity name
        seed := 1
        evilBro := entities get(name)
        while(evilBro != null) {
            name = "%s__%d" format(entity name, seed)
            seed += 1
            evilBro = entities get(name)
        }
        
        entities put(name, entity)
        entity engine = this
        entity onAdd()
    }
    
    getEntity: func (name: String) -> Entity {
        return entities get(name)
    }
    
    getEntity: func ~over <T> (name: String, T: Class) -> T {
		ent := entities get(name)
		if(!ent class inheritsFrom(T)) {
            Exception new(This, "Attempting to get (%s, %s), but the entity has incompatible type %s" format(name, T name, ent class name)) throw()
        }
        return ent
	}
    
    run: func {
        // Disabled for debugging
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
	
	/*
	addSpawnable: func(name: String, ent: Entity) {
		spawnables put(name,ent class)
	}
	
	spawn: func(className,name: String,pos: Float3) -> Bool {
		ent := spawnables get(className)
		if(ent == null)
			return false
			
		spawned := ent new(name)
		//spawned setPos(pos)
		
		addEntity(spawned)
		
		return true
	}
	*/
}
