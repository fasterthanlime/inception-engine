import math
import engine/[Entity, Types]
import Geometry, Sphere, Box

/**
 * Check collision beetween sphere and box in plane XY.
 *
 * @version 1.0.0, 2010-09-14
 */
sphereBoxCH: func (sphere: Sphere, box: Box, reaction: Float3) -> Bool {
    
    boxScale     := box get("scale", Float3)
    boxAngles    := box get("eulerAngles", Float3)
    
    sphereRadius := sphere get("radius", Float)
    
    // Translation, now box is centered at (0, 0)
    sphereCenter := sphere get("position", Float3) -
        box get("position", Float3)
    
    // Rotation, now box border are axis aligned
    rotationAngle := -boxAngles x
    (sphereCenter x, sphereCenter y) = (
        sphereCenter x * cos(rotationAngle) -
            sphereCenter y * sin(rotationAngle),
        sphereCenter x * sin(rotationAngle) +
            sphereCenter y * cos(rotationAngle))
    
    // Checking forms intersection
    intersect  := false
    halfWidth  := boxScale x / 2
    halfHeight := boxScale y / 2
    if (sphereCenter x >= -halfWidth &&
        sphereCenter x <= halfWidth) {

        if (sphereCenter y > 0) {
            reaction y = halfHeight - (sphereCenter y - sphereRadius)
            intersect = reaction y >= 0
        } else {
            reaction y = -halfHeight - (sphereCenter y + sphereRadius)
            intersect = reaction y <= 0
        }
    } else if (sphereCenter y >= -halfHeight &&
        sphereCenter y <= halfHeight) {
    
        if (sphereCenter x > 0) {
            reaction x = halfWidth - (sphereCenter x - sphereRadius)
            intersect = reaction x >= 0
        } else {
            reaction x = -halfWidth - (sphereCenter x + sphereRadius)
            intersect = reaction x <= 0
        }
    }
    
    if (intersect)
    {
        // Rotate reaction vector
        rotationAngle := boxAngles x
        (reaction x, reaction y) = (
            reaction x * cos(rotationAngle) -
                reaction y * sin(rotationAngle),
            reaction x * sin(rotationAngle) +
                reaction y * cos(rotationAngle))
    }

    return intersect
}
