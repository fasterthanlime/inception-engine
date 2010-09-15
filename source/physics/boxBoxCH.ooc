import math
import engine/[Entity, Types]
import Geometry, Box, calculateAABB

/**
 * Check collision beetween two box. Only works in plane XY.
 *
 * @version 1.0.1, 2010-09-15
 */
boxBoxCH: func (box1, box2: Box, reaction: Float3) -> Bool {

    alpha := box1 get("eulerAngles", Float3) x
    // Calculate AABB of box2 in new system coordinate
    (minPt, maxPt) := calculateAABB(
        box2,
        box1 get("position", Float3),
        alpha)

    // Checking forms intersection using "Separating axis theorem"
    box1Scale := box1 get("scale", Float3)
    halfWidth  := box1Scale x / 2
    halfHeight := box1Scale y / 2        
    if (minPt x <= halfWidth &&
        maxPt x >= -halfWidth &&
        minPt y <= halfHeight &&
        maxPt y >= -halfHeight) {

        if (maxPt x - minPt x >= 0) {
            reaction x = halfWidth - minPt x
        } else {
            reaction x = -halfWidth - maxPt x
        }
        if (maxPt y - minPt y >= 0) {
            reaction y = halfHeight - minPt y
        } else {
            reaction y = -halfHeight - maxPt y
        }
        reaction z = 0

        // Rotate reaction vector
        (reaction x, reaction y) = (
            reaction x * cos(alpha) -
                reaction y * sin(alpha),
            reaction x * sin(alpha) +
                reaction y * cos(alpha))

        return true
    }

    return false
}
