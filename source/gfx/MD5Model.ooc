/*
 * md5model.h -- md5mesh model loader + animation
 * last modification: aug. 14, 2007
 *
 * Copyright (c) 2005-2007 David HENRY
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
 *
 * gcc -Wall -ansi -lGL -lGLU -lglut md5anim.c md5anim.c -o md5model
 */

// Vectors
Vec2: cover {
    x, y: Float
}

Vec3: cover {
    x, y, z: Float
}

// Quaternion (x, y, z, w)
Quat4: class {
    x, y, z, w: Float
    
    init: func (=x, =y, =z, =w) {}
    
    computeW: func {
        t := 1.0f - (q[X] * q[X]) - (q[Y] * q[Y]) - (q[Z] * q[Z]);

        if (t < 0)
            q[W] = 0
        else
            q[W] = -sqrt(t)
    }
    
    normalize: func {
        /* compute magnitude of the quaternion */
        float mag = sqrt ((q[X] * q[X]) + (q[Y] * q[Y]) + (q[Z] * q[Z]) + (q[W] * q[W]))

        /* check for bogus length, to protect against divide by zero */
        if (mag > 0.0f) {
            /* normalize it */
            float oneOverMag = 1.0f / mag

            q[X] *= oneOverMag
            q[Y] *= oneOverMag
            q[Z] *= oneOverMag
            q[W] *= oneOverMag
        }
    }
    
    multQuat: func (b, out: Quat4) {
        out[W] = (qa[W] * qb[W]) - (qa[X] * qb[X]) - (qa[Y] * qb[Y]) - (qa[Z] * qb[Z])
        out[X] = (qa[X] * qb[W]) + (qa[W] * qb[X]) + (qa[Y] * qb[Z]) - (qa[Z] * qb[Y])
        out[Y] = (qa[Y] * qb[W]) + (qa[W] * qb[Y]) + (qa[Z] * qb[X]) - (qa[X] * qb[Z])
        out[Z] = (qa[Z] * qb[W]) + (qa[W] * qb[Z]) + (qa[X] * qb[Y]) - (qa[Y] * qb[X])
    }
    
    multVec (const quat4_t q, const vec3_t v, quat4_t out)
    {
        out[W] = - (q[X] * v[X]) - (q[Y] * v[Y]) - (q[Z] * v[Z]);
        out[X] =   (q[W] * v[X]) + (q[Y] * v[Z]) - (q[Z] * v[Y]);
        out[Y] =   (q[W] * v[Y]) + (q[Z] * v[X]) - (q[X] * v[Z]);
        out[Z] =   (q[W] * v[Z]) + (q[X] * v[Y]) - (q[Y] * v[X]);
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





















