
Property: abstract class {
    
    name: String
    
    init: func ~withName(=name) {}
    
}

GenericProperty: class <T> extends Property {
    
    value: T
    
    init: func ~gp(.name, =value) {
        super(name)
    }
    
    set: func (=value) {}
    get: func -> T { value }
    
}
