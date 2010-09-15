import math
import engine/[Entity, Types]
import Geometry, Sphere

/**
 * Check collision beetween two spheres. General implementation, works
 * in 2D and 3D.
 *
 * @version 1.0.1, 2010-09-15
 */
sphereSphereCH: func (sphere1, sphere2: Sphere, reaction: Float3) -> Bool {

    reaction               = sphere2 get("position", Float3) -
                                sphere1 get("position", Float3)
    currentSquaredDistance := reaction squaredLength()
    squaredDistance        := sphere1 get("radius", Float) +
                                sphere2 get("radius", Float)
    squaredDistance        = squaredDistance*squaredDistance

    if (currentSquaredDistance <= squaredDistance) {
        factor = sqrt(squaredDistance) - sqrt(currentSquaredDistance) : Float
        reaction = reaction * factor / reaction length()
        return true
    } else {
        return false
    }
}
