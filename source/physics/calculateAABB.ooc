import math
import engine/[Entity, Types]
import Geometry, Box

/**
 * Determine AABB of a box against xy axis rotated of angle alpha from
 * XY axis.
 *
 * @version 1.0.0, 2010-09-15
 * @param   box                 original box from which AABB is
 *                              determinated.
 * @param   origin              origin of new coordinate system in
 *                              usual coordinate system.
 * @param   alpha               orientation of coordinate system
 *                              relative to usual coordinate system.
 * @return  (Float3, Float3)    min and max points determining AABB
 *                              surface.
 */
calculateAABB: func (box: Box, origin: Float3, alpha: Float) -> (Float3, Float3) {

    boxScale    := box get("scale", Float3)
    boxAngles   := box get("eulerAngles", Float3)

    halfWidth  := boxScale x / 2
    halfHeight := boxScale y / 2
    
    // Change coordinate system
    
    // 1. Translation
    boxCenter := box get("position", Float3) - origin
    
    // 2. Rotation,
    rotationAngle := -alpha
    (boxCenter x, boxCenter y) = (
        boxCenter x * cos(rotationAngle) -
            boxCenter y * sin(rotationAngle),
        boxCenter x * sin(rotationAngle) +
            boxCenter y * cos(rotationAngle))
    
    // Calculate all corners position
    rotationAngle = boxAngles x - alpha
    // TODO: can certainly be optimized.
    corner1 := Float2 new(halfWidth * cos(rotationAngle) -
            halfHeight * sin(rotationAngle),
        halfWidth * sin(rotationAngle) +
            halfHeight * cos(rotationAngle))
    corner2 := Float2 new(halfWidth * cos(rotationAngle) -
            halfHeight * sin(rotationAngle),
        halfWidth * sin(rotationAngle) +
            halfHeight * cos(rotationAngle))
    corner3 := Float2 new(halfWidth * cos(rotationAngle) +
            halfHeight * sin(rotationAngle),
        halfWidth * sin(rotationAngle) -
            halfHeight * cos(rotationAngle))
    corner4 := Float2 new(halfWidth * cos(rotationAngle) +
            halfHeight * sin(rotationAngle),
        halfWidth * sin(rotationAngle) -
            halfHeight * cos(rotationAngle))
            
    minPt := Float2 new(boxCenter x +
            corner1 x min(corner2 x, corner3 x, corner4 x),
        boxCenter y +
            corner1 y min(corner2 y, corner3 y, corner4 y))
    maxPt := Float2 new(boxCenter x +
            corner1 x max(corner2 x, corner3 x, corner4 x),
        boxCenter y +
            corner1 y max(corner2 y, corner3 y, corner4 y))
            
    return (minPt, maxPt)
}
