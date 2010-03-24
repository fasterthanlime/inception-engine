import structs/ArrayList
import Entity, Update

Engine: class {
    
    entities: Entity[]
    
    init: func {}
    
    addEntity: func (entity: Entity) {
        entities add(entity)
    }
    
    run: func {
        
    }
    
}
