import structs/[ArrayList, HashMap]
import Property, Update

Entity: class {
    
    name: String
    id: Int
    
    props := HashMap<String, Property> new()
    updates : Update[]
    
    idSeed := static 0
    
    init: func ~withName(=name) {
        This idSeed += 1
        id = This idSeed
    }
    
    addUpdate: func (update: Update) { updates add(update) }
    
    update: func {
        //printf("[%d] %s got %d updates to run\n", id, name, updates size())
        iter := updates iterator()
        while(iter hasNext()) {
            if(!iter next() run()) {
                iter remove()
            }
        }

    }
    
}
