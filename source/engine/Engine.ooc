use sdl,glew
import glew
import sdl/[Sdl, Event]
import structs/HashMap
import Entity, Update, Message
import io/File
import gfx/Scene

Engine: class extends Entity {
    
    entities := HashMap<String, Entity> new()
    spawnables := HashMap<String, Func(String) -> Entity> new()
	
	/*
    spawn("machin")
    f := map get("machin")
    addEntity(f("abeuh"))
    */
    
    
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
        return entities get(name)
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
	
	addSpawnable: func(name: String, f:Func(String) -> Entity) {
		spawnables put(name,f)
	}
	
	spawn: func(className,name: String,pos: Float3) -> Bool {
		f := spawnables get(className)
		if(f == null)
			return false
			
		addEntity(f(name))
		
		return true
	}
}
