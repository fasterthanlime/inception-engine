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
    
}
