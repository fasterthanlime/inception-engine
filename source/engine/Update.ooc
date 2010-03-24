import Entity

Update: class {
    
    f: Func (Entity) -> Bool
    
    init: func ~withFunc (=f) {}
    
    run: func (entity: Entity) -> Bool {
        f(entity)
    }
    
}
