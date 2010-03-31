import engine/Types

Property: abstract class {
    
    name: String
    
    init: func ~withName(=name) {}
    
    toString: func -> String {
        class name
    }
    
}

GenericProperty: class <T> extends Property {
    
    value: T
    
    init: func ~gp(.name, =value) {
        super(name)
    }
    
    set: func (=value) {}
    get: func -> T { value }
    
    toString: func -> String {
        match(T) {
            case String =>
                value as String
            case Float =>
                "%.2f" format(value as Float)
            case Int =>
                "%d" format(value as Int)
            case Float2 =>
                f := value as Float2
                "(%.2f, %.2f)" format(f x, f y)
            case Float3 =>
                f := value as Float3
                "(%.2f, %.2f, %.2f)" format(f x, f y, f z)
            case =>
                super()
        }
    }
    
}

