import engine/[Entity, Types]
import Geometry, Box, Sphere, sphereSphereCH, sphereBoxCH, boxBoxCH
import ooc-hackit

/**
 * CollisionHandler factory used to retrieve current implementation
 * of collision checking beetween two (sub-)types of Geometry.
 *
 * @version 1.0.0, 2010-09-14
 */
CollisionHandlerFactory: abstract class {

    /**
     * Stupid implementation for current need. Add
     * a map<(class,class),CollisionHandler> later.
     */
    getHandler: static func(geometry1, geometry2: Geometry) -> Func (Geometry, Geometry, Float3) -> Bool {
        match (geometry1 class) {
            case Sphere =>
                match (geometry2 class) {
                    case Sphere =>
                        return sphereSphereCH
                    case Box =>
                        return sphereBoxCH
                }
            case Box =>
                match (geometry2 class) {
                    case Sphere =>
                        return sphereBoxCH
                    case Box =>
                        return boxBoxCH
                }
        }
        
        return Closure nullFunc()
    }
}
