import structs/HashMap
import Entity, Update

Engine: class {
    
    entities := HashMap<String, Entity> new()
    
    init: func {}
    
    addEntity: func (entity: Entity) {
        // TODO: check for duplicates
        entities put(entity name, entity)
        entity engine = this
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
    
    exit: func {
		exit(0)
	}
}
