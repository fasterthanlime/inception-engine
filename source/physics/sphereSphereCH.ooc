import math
import engine/[Entity, Types]
import Geometry, Sphere

/**
 * Check collision beetween two spheres. General implementation, works
 * in 2D and 3D.
 *
 * @version 1.0.0, 2010-09-14
 */
sphereSphereCH: func (sphere1, sphere2: Sphere, reaction: Float3) -> Bool {

    pos1    := sphere1 get("position", Float3)
    radius1 := sphere1 get("radius",   Float)
    
    pos2    := sphere2 get("position", Float3)
    radius2 := sphere2 get("radius",   Float)

    diffX    := pos2 x - pos1 x
    diffY    := pos2 y - pos1 y
    diffZ    := pos2 z - pos1 z
    currentSquareDistance := diffX*diffX + diffY*diffY + diffZ*diffZ
    squareDistance := (radius1 + radius2)*(radius1 + radius2)
    if (currentSquareDistance <= squareDistance) {
        factor := sqrt(currentSquareDistance/squareDistance)
        reaction set(diffX*(factor-1), diffY*(factor-1), diffZ*(factor-1))
        return true
    } else {
        return false
    }
}
