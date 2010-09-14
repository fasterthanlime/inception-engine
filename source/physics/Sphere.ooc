import engine/[Entity, Types]
import Geometry

Sphere: class extends Geometry {

    init: func (.name, radius) {
        super(name)
        set("radius", radius)
    }
}
