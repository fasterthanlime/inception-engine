import engine/Types
import text/StringTokenizer

Property: abstract class {
    
    name: String
    
    init: func ~withName(=name) {}
    
    toString: func -> String {
        class name
    }
    
    fromString: abstract func (st: StringTokenizer) -> String
    
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
                "%.4f" format(value as Float)
            case Int =>
                "%d" format(value as Int)
            case Float2 =>
                f := value as Float2
                "(%.4f, %.4f)" format(f x, f y)
            case Float3 =>
                f := value as Float3
                "(%.4f, %.4f, %.4f)" format(f x, f y, f z)
            case =>
                T name
        }
    }
    
    fromString: func (st: StringTokenizer) -> String {
        match(T) {
            case String =>
                tok := st nextToken()
                if(!tok) return "Missing value!"
                set(tok)
                ""
            case Float =>
                tok := st nextToken()
                if(!tok) return "Missing value!"
                set(tok toFloat())
                ""
            case Int =>
                tok := st nextToken()
                if(!tok) return "Missing value!"
                set(tok toInt())
                ""
            case Float2 =>
				x := st nextToken()
				y := st nextToken()
				if(!x || !y) return "Need 2 values."
				set(Float2 new(x toFloat(), y toFloat()))
				""
			case Float3 =>
				x := st nextToken()
				y := st nextToken()
				z := st nextToken()
				if(!x || !y || !z) return "Need 3 values."
				set(Float3 new(x toFloat(), y toFloat(), z toFloat()))
				""
            // TODO: add other types
            case =>
				("Don't know how to set property " + name + " with value " + toString() + " of type " + T name)
        }
    }
    
}

