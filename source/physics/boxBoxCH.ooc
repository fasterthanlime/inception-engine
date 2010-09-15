import math
import engine/[Entity, Types]
import Geometry, Box

/**
 * .
 *
 * @version 1.0.0, 2010-09-14
 */
boxBoxCH: func (box1, box2: Box, reaction: Float3) -> Bool {

    angles1 := box1 get("eulerAngles", Float3)
    
    center2 := box2 get("position", Float3) -
        box1 get("position", Float3)
    angles2 := box2 get("eulerAngles", Float3)
    
     

    // TODO
    return false
}
