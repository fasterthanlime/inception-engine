import math
import engine/[Entity, Types]
import Geometry, Box, calculateAABB

abs: func (f: Float) -> Float { f < 0 ? -f : f }

/**
 * Check collision beetween two 2D boxes. Only works in plane XY.
 *
 * @version 1.0.1, 2010-09-15
 */
boxBoxCH: func (box1, box2: Box, reaction: Float3) -> Bool {

    b1Center := box1 get("position", Float3)
    b1Scale  := box1 get("scale", Float3)
    b1Alpha  := box1 get("eulerAngles", Float3) z
    
    b2Center := box2 get("position", Float3)
    b2Scale  := box2 get("scale", Float3)
    b2Alpha  := box2 get("eulerAngles", Float3) z

    /*
    (
     "Box-box! [" + b1Center toString() + " x " + b1Scale toString() + (" °%.2f] vs [" format(b1Alpha)) +
                    b2Center toString() + " x " + b2Scale toString() + (" °%.2f]" format(b2Alpha))
    ) println()
    */
    
    b1Alpha *= (PI / 180.0)
    b2Alpha *= (PI / 180.0)

    b1Cos := cos(-b1Alpha)
    b1Sin := sin(-b1Alpha)

    // compute x and y axis of box 2
    xAxis := Float2 new(
        cos(b2Alpha),
        sin(b2Alpha)
    )
    xAxis normalize()

    yAxis := Float2 new(
        -sin(b2Alpha),
         cos(b2Alpha)
    )
    yAxis normalize()

    //("xAxis = " + xAxis toString() + " / yAxis = " + yAxis toString()) println()

    /*
        x' = cos(theta) * x - sin(theta) * y
        y' = sin(theta) * x + cos(theta) * y 
     */

    // compute corners of box 1, and test them one by one
    for(i in 0..3) {
    
        corner := Float2 new(
            b1Center x + (b1Cos * b1Scale x - b1Sin * b1Scale y) - b2Center x,
            b1Center y + (b1Sin * b1Scale x + b1Cos * b1Scale y) - b2Center y
        )
        if(isIn(xAxis, yAxis, b2Center, b2Scale, corner, reaction)) return true

        corner set(
            b1Center x + (b1Cos * -b1Scale x - b1Sin * b1Scale y) - b2Center x,
            b1Center y + (b1Sin * -b1Scale x + b1Cos * b1Scale y) - b2Center y
        )
        if(isIn(xAxis, yAxis, b2Center, b2Scale, corner, reaction)) return true

        corner set(
            b1Center x + (b1Cos * -b1Scale x - b1Sin * -b1Scale y) - b2Center x,
            b1Center y + (b1Sin * -b1Scale x + b1Cos * -b1Scale y) - b2Center y
        )
        if(isIn(xAxis, yAxis, b2Center, b2Scale, corner, reaction)) return true

        corner set(
            b1Center x + (b1Cos * b1Scale x - b1Sin * -b1Scale y) - b2Center x,
            b1Center y + (b1Sin * b1Scale x + b1Cos * -b1Scale y) - b2Center y
        )
        if(isIn(xAxis, yAxis, b2Center, b2Scale, corner, reaction)) return true

        // re-test with a smaller cube
        b1Scale x *= 0.8
        b1Scale y *= 0.8
    }

    return false

}

isIn: func (xAxis, yAxis: Float2, b2Center, b2Scale: Float3, corner: Float2, reaction: Float3) -> Bool {

    //("Testing corner " + corner toString() + ", axis = " + xAxis toString() + " | " + yAxis toString()) println()

    // testing on X axis
    cdotX := corner dot(xAxis)
    diff1 := b2Scale x
    diff2 := -b2Scale x
    inX := (cdotX < diff1 && cdotX > diff2)
    //("cdotX = %.2f, in = %d, [%.2f - %.2f]" format(cdotX, inX, diff1, diff2)) println()

    // testing on Y axis
    cdotY := corner dot(yAxis)
    diff3 := b2Scale y
    diff4 := -b2Scale y
    inY := (cdotY < diff3 && cdotY > diff4)
    //("cdotY = %.2f, in = %d, [%.2f - %.2f]" format(cdotY, inY, diff3, diff4)) println()

    // compute correction
    if(inX && inY) {
        nearest := 1
        nearestDist := diff1 - cdotX

        //"diffs 1/2/3/4 = %.2f / %.2f / %.2f / %.2f" printfln(diff1 - cdotX, cdotX - diff2, diff3 - cdotY, cdotY - diff4)

        if(cdotX - diff2 < nearestDist) {
            nearest = 2
            nearestDist = cdotX - diff2
        }

        if(diff3 - cdotY < nearestDist) {
            nearest = 3
            nearestDist = diff3 - cdotY
        }

        if(cdotY - diff4 < nearestDist) {
            nearest = 4
            nearestDist = cdotY - diff4
        }

        match (nearest) {
            case 1 =>
                //"Correcting minus X" println()
                reaction set(
                    (diff1 - cdotX) * xAxis x,
                    (diff1 - cdotX) * xAxis y,
                    0
                )
            case 2 =>
                //"Correcting plus  X" println()
                reaction set(
                    (diff2 - cdotX) * xAxis x,
                    (diff2 - cdotX) * xAxis y,
                    0
                )
            case 3 =>
                //"Correcting minus Y" println()
                reaction set(
                    (diff3 - cdotY) * yAxis x,
                    (diff3 - cdotY) * yAxis y,
                    0
                )
            case 4 =>
                //"Correcting plus  Y" println()
                reaction set(
                    (diff4 - cdotY) * yAxis x,
                    (diff4 - cdotY) * yAxis y,
                    0
                )
        }
        
        return true
    }

    false

}




