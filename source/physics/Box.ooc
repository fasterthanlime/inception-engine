import engine/[Entity, Types]
import Geometry

Box: class extends Geometry {

    init: func (.name, scale: Float3, eulerAngles: Float3) {
        super(name)
        set("scale", scale clone())
        set("eulerAngles", eulerAngles clone())
    }
}
