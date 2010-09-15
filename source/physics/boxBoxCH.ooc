import math
import engine/[Entity, Types]
import Geometry, Box

/**
 * Check collision beetween two box. Only works in plane XY.
 *
 * @version 1.0.0, 2010-09-14
 */
boxBoxCH: func (box1, box2: Box, reaction: Float3) -> Bool {

    box1Scale    := box1 get("scale", Float3)
    box1Angles   := box1 get("eulerAngles", Float3)
    
    box2Scale    := box2 get("scale", Float3)
    box2Angles   := box2 get("eulerAngles", Float3)
    
    // Translation, now box1 is centered at (0, 0)
    box2Center := box2 get("position", Float3) -
        box1 get("position", Float3)
    
    // Rotation, now box1 border are axis aligned
    rotationAngle := -box1Angles x
    (box2Center x, box2Center y) = (
        box2Center x * cos(rotationAngle) -
            box2Center y * sin(rotationAngle),
        box2Center x * sin(rotationAngle) +
            box2Center y * cos(rotationAngle))
    box2Angles x = box2Angles x + rotationAngle
    
    // Checking forms intersection using "Separating axis theorem"
    halfWidth  := box2Scale x / 2
    halfHeight := box2Scale y / 2
    
    rotationAngle = box2Angles x
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
            
    minPt := Float2 new(box2Center x +
            corner1 x min(corner2 x, corner3 x, corner4 x),
        box2Center y +
            corner1 y min(corner2 y, corner3 y, corner4 y))
    maxPt := Float2 new(box2Center x +
            corner1 x max(corner2 x, corner3 x, corner4 x),
        box2Center y +
            corner1 y max(corner2 y, corner3 y, corner4 y))

    halfWidth  = box1Scale x / 2
    halfHeight = box1Scale y / 2        
    if (minPt x <= halfWidth &&
        maxPt x >= -halfWidth &&
        minPt y <= halfHeight &&
        maxPt y >= -halfHeight) {

        if (box2Center x >= 0) {
            reaction x = halfWidth - minPt x
        } else {
            reaction x = -halfWidth - maxPt x
        }
        if (box2Center y >= 0) {
            reaction y = halfHeight - minPt y
        } else {
            reaction y = -halfHeight - maxPt y
        }        

        // Rotate reaction vector
        rotationAngle := box1Angles x
        (reaction x, reaction y) = (
            reaction x * cos(rotationAngle) -
                reaction y * sin(rotationAngle),
            reaction x * sin(rotationAngle) +
                reaction y * cos(rotationAngle))

        return true
    }

    return false
}
