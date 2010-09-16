import engine/[Entity, Types]
import Geometry

Box: class extends Geometry {

    init: func (.name) {
        super(name)
        set("scale", Float3 new(1, 1, 1))
        set("eulerAngles", Float3 new(0, 0, 0))
    }
    
}

