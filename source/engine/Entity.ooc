
Entity: class {
    
    name: String
    id: Int
    
    idSeed := static 0
    
    init: func ~withName(=name) {
        This idSeed += 1
        id = This idSeed
    }
    
}
