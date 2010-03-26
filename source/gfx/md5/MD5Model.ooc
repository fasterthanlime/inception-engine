/**
 * md5model.h -- md5mesh model loader + animation
 *
 * Copyright (c) 2005-2007 David HENRY
 * Copyright (c) 2010-2011 Amos Wenger <amoswenger@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or
 * sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
 * ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

use math

// Vectors
Vec2: cover {
    x, y: Float
}

Vec3: cover {
    x, y, z: Float
}

// Quaternion (x, y, z, w)
Quat4: cover {
    
    x, y, z, w: Float
    
    init: func@ (=x, =y, =z, =w) {}
    
    computeW: func@ {
        t := 1 - (x * x) - (y * y) - (z * z);

        if (t < 0)
            w = 0
        else
            w = -sqrt(t)
    }
    
    normalize: func {
        // compute magnitude of the quaternion
        mag := sqrt ((x * x) + (y * y) + (z * z) + (w * w))

        /* check for bogus length, to protect against divide by zero */
        if (mag > 0) {
            /* normalize it */
            oneOverMag := 1 / mag

            x *= oneOverMag
            y *= oneOverMag
            z *= oneOverMag
            w *= oneOverMag
        }
    }
    
    multQuat: func (qb: Quat4) -> Quat4 {
        qa : Quat4 = this
        out: Quat4
        out w = (qa w * qb w) - (qa x * qb x) - (qa y * qb y) - (qa z * qb z)
        out x = (qa x * qb w) + (qa w * qb x) + (qa y * qb z) - (qa z * qb y)
        out y = (qa y * qb w) + (qa w * qb y) + (qa z * qb x) - (qa x * qb z)
        out z = (qa z * qb w) + (qa w * qb z) + (qa x * qb y) - (qa y * qb x)
        out
    }
    
    multVec: func (v: Vec3) -> Quat4 {
        out: Quat4
        out w = 0 - (x * v x) - (y * v y) - (z * v z)
        out x =     (w * v x) + (y * v z) - (z * v y)
        out y =     (w * v y) + (z * v x) - (x * v z)
        out z =     (w * v z) + (x * v y) - (y * v x)
        out
    }
    
    inverse: func -> Quat4 {
        inv: Quat4
        inv x = -x; inv y = -y
        inv z = -z; inv w =  w
        inv
    }
    
    rotatePoint: func@ (in: Vec3) -> Vec3 {
        inv := inverse() .normalize()
        result := multVec(in) multQuat(inv)
        
        out: Vec3
        out x = result x
        out y = result y
        out z = result z
        out
    }
}

/* Joint */
MD5Joint: cover {
    name: Char[64]
    parent: Int
    
    pos: Vec3
    orient: Quat4
}

/* Vertex */
MD5Vertex: cover {
    st: Vec2

    start: Int /* start weight */
    count: Int /* weight count */
}

/* Triangle */
MD5Triangle: cover {
    index: Int[3]
}

/* Weight */
MD5Weight: cover {
    joint: Int
    bias: Float

    pos: Vec3
}

/* Bounding box */
MD5BBox: cover {
    min, max: Vec3
}

/* MD5 mesh */
MD5Mesh: cover {
    vertices : MD5Vertex*
    triangles: MD5Triangle*
    weights  : MD5Weight*

    numVerts, numTris, numWeights: Int

    shader: Char[256]
}

/* MD5 model structure */
MD5Model: cover {
    baseSkel : MD5Joint*
    meshes   : MD5Mesh*
    
    numJoints, numMeshes: Int
}

/* Animation data */
MD5Anim: cover {
    numFrames, numJoints, frameRate: Int
    
    skelFrames: MD5Joint**
    bboxes:     MD5BBox*
}

/* Animation info */
AnimInfo: cover {
    currFrame, nextFrame: Int
    
    lastTime, maxTime: Double
}


















