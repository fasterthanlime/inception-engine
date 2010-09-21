/*
 * md5mesh model loader + animation
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

use math, glew
import glew, math

import structs/ArrayList
import ../[Model, Texture]
import engine/Types

// Vectors
Vec2: cover {
    x, y: Float
    
    init: func@ ~zero { x = y = 0 }
    init: func@ ~xy (=x, =y) {}
}

Vec3: cover {
    x, y, z: Float
    
    init: func@ ~zero { x = y = z = 0 }
    init: func@ ~xyz (=x, =y, =z) {}
}

// Quaternion (x, y, z, w)
Quat4: cover {
    
    x, y, z, w: Float
    
    init: func@ (=x, =y, =z, =w) {}
    
    computeW: func@ {
        t := 1.0 - (x * x) - (y * y) - (z * z)

        if (t < 0.0)
            w = 0.0
        else
            w = -sqrt(t)
    }
    
    normalize: func -> Quat4 {
        out: Quat4
        
        // compute magnitude of the quaternion
        mag := sqrt ((x * x) + (y * y) + (z * z) + (w * w))

        /* check for bogus length, to protect against divide by zero */
        if (mag > 0.0) {
            /* normalize it */
            oneOverMag := 1.0 / mag

            out x = x * oneOverMag
            out y = y * oneOverMag
            out z = z * oneOverMag
            out w = w * oneOverMag
        }
        
        out
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
        out w = 0.0 - (x * v x) - (y * v y) - (z * v z)
        out x =       (w * v x) + (y * v z) - (z * v y)
        out y =       (w * v y) + (z * v x) - (x * v z)
        out z =       (w * v z) + (x * v y) - (y * v x)
        out
    }
    
    inverse: func -> Quat4 {
        inv: Quat4
        inv x = -x; inv y = -y
        inv z = -z; inv w =  w
        inv
    }
    
    rotatePoint: func (in: Vec3) -> Vec3 {
        inv := inverse()
        inv = inv normalize()
        
        tmp := multVec(in)
        result := tmp multQuat(inv)
        
        out: Vec3
        out x = result x
        out y = result y
        out z = result z
        out
    }
}

/* Joint */
MD5Joint: class {
    name: Char*
    parent: Int
    
    pos: Vec3
    orient: Quat4
    
    init: func {
        name = gc_malloc(64)
    }
}

/* Vertex */
MD5Vertex: cover {
    st: Vec2 // UV coordinates

    start: Int // start weight
    count: Int // weight count
}

/* Triangle */
MD5Triangle: cover {
    a, b, c: Int // indices of the three vertices composing the face
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
MD5Mesh: class {
    vertices : MD5Vertex*
    triangles: MD5Triangle*
    weights  : MD5Weight*

    numVerts, numTris, numWeights: Int

    shader: Char*
    textureID: GLuint = -1
    
    init: func {
        shader = gc_malloc(256)
    }
}

/* MD5 model structure */
MD5Model: class extends Model {
    baseSkel : MD5Joint*
    meshes   : MD5Mesh*
    
    numJoints, numMeshes: Int
    maxVerts, maxTris: Int
    
    vertexArray   : GLfloat*
    texCoordArray : GLfloat*
    vertexIndices : GLuint*
    
    animated := false
    
    init: func ~md5 (.name) {
        super(name)
    }
    
    clone: func -> This {
        // That's ee-vil.
        copy := gc_malloc(This instanceSize) as This
        memcpy(copy, this, This instanceSize)
        copy pos = Float3 new()
        copy rot = Float3 new()
        copy
    }
    
    /**
     * Prepare a mesh for drawing.  Compute mesh's final vertex positions
     * given a skeleton.  Put the vertices in vertex arrays.
     */
    prepareMesh: func (mesh: MD5Mesh, skeleton: MD5Joint*) {
        
        if(mesh textureID == -1) {
            printf("Loading texture '%s'\n", mesh shader)
            mesh textureID = Texture loadGLImage(mesh shader)
            printf("Finished loading '%s', got ID %d!\n", mesh shader, mesh textureID)
        }
        
        {
            i := 0
            /* Setup vertex indices */
            while(i < mesh numTris) {
                //printf("---------- triangle #%d / #%d -------- storing to %d, %d, %d\n", i, mesh numTris, i*3, i*3 + 1, i*3 + 2)
                vertexIndices[i*3    ] = mesh triangles[i] a
                vertexIndices[i*3 + 1] = mesh triangles[i] b
                vertexIndices[i*3 + 2] = mesh triangles[i] c
                //printf("got indices %d, %d, %d\n", mesh triangles[i] a, mesh triangles[i] b, mesh triangles[i] c)
                i += 1
            }
        }

        // Setup vertices
        for (i in 0..mesh numVerts) {
            
            finalVertex := Vec3 new()
            
            //printf("---------- vertex #%d / #%d --------\n", i, mesh numVerts)
            
            weightStart := mesh vertices[i] start
            weightCount := mesh vertices[i] count
            
            // Calculate final vertex to draw with weights
            for (j in 0..weightCount) {
                weight := mesh weights[weightStart + j]
                joint  := skeleton[weight joint]

                // Calculate transformed vertex for this weight
                wv := joint orient rotatePoint(weight pos)
                
                //printf("transformed vertex = (%.2f, %.2f, %.2f), jointpos = (%.2f, %.2f, %.2f), weightpos = (%.2f, %.2f, %.2f), weight bias = %.2f\n",
                //   wv x, wv y, wv z, joint pos x, joint pos y, joint pos z, weight pos x, weight pos y, weight pos z, weight bias)

                // The sum of all weight->bias should be 1.0
                finalVertex x += (joint pos x + wv x) * weight bias
                finalVertex y += (joint pos y + wv y) * weight bias
                finalVertex z += (joint pos z + wv z) * weight bias
            }
            
            //printf("final finalVertex = (%.2f, %.2f, %.2f), storing to %d, %d, %d\n", finalVertex x, finalVertex y, finalVertex z, i*3, i*3+1, i*3+2)
            vertexArray[i*3    ] = finalVertex x
            vertexArray[i*3 + 1] = finalVertex y
            vertexArray[i*3 + 2] = finalVertex z
            
            texCoordArray[i*2    ] = mesh vertices[i] st x
            texCoordArray[i*2 + 1] = mesh vertices[i] st y
        }
        
        //printf("Finished preparing mesh, vertexArray = %.2f, %.2f, %.2f, ...\n", vertexArray[0], vertexArray[1], vertexArray[2])
    }

    allocVertexArrays: func {
        vertexArray   = gc_malloc(Float size * maxVerts * 3) // 3 floats per vertex
        texCoordArray = gc_malloc(Float size * maxVerts * 2) // 2 floats per vertex
        vertexIndices = gc_malloc(UInt  size * maxTris  * 3) // 3 indices per faces
    }
    
    /**
     * Draw the skeleton as lines and points (for joints).
     */
    drawSkeleton: func (skeleton: MD5Joint*, numJoints: Int) {
        i: Int

        // Draw each joint
        glPointSize(5.0)
        glColor3f(1.0, 0.0, 0.0)
        glBegin(GL_POINTS)
        for (i in 0..numJoints)
            glVertex3fv (skeleton[i] pos&)
        glEnd()
        glPointSize(1.0)

        // Draw each bone
        glColor3f (0.0, 1.0, 0.0)
        glBegin (GL_LINES)
        for (i in 0..numJoints) {
            //printf("%d's parent = %d, pos = (%.2f, %.2f, %.2f)\n", i, skeleton[i] parent, skeleton[i] pos x, skeleton[i] pos y, skeleton[i] pos z)
            if (skeleton[i] parent != -1) {
                glVertex3fv(skeleton[skeleton[i] parent] pos&)
                glVertex3fv(skeleton[i] pos&)
            }
        }
        glEnd()
    }

    render: func {
        
        skeleton : MD5Joint*
        
        if (animated) {
            /*
            // Calculate current and next frames
            animate(md5anim, animInfo, currentTime - lastTime);

            // Interpolate skeletons between two frames
            interpolateSkeletons(md5anim skelFrames[animInfo currFrame],
			    md5anim skelFrames[animInfo next_frame],
			    numJoints,
			    animInfo lastTime * md5anim frameRate,
			    skeleton);
            */
        } else {
            // No animation, use bind-pose skeleton
            skeleton = baseSkel
        }
        
        // Draw skeleton
        drawSkeleton(skeleton, numJoints)

        glColor3f(1.0, 1.0, 1.0)
        glEnable(GL_TEXTURE_2D)
        glEnable(GL_CULL_FACE)
        glFrontFace(GL_CW)

        glEnableClientState(GL_VERTEX_ARRAY)
        glEnableClientState(GL_TEXTURE_COORD_ARRAY)

        // Draw each mesh of the model
        for (i in 0..numMeshes) {
            //prepareMesh(meshes[i], skeleton)
            glBindTexture(GL_TEXTURE_2D, meshes[i] textureID)
            glVertexPointer  (3, GL_FLOAT, 0, vertexArray)
            glTexCoordPointer(2, GL_FLOAT, 0, texCoordArray)
            
            glDrawElements(GL_TRIANGLES, meshes[i] numTris * 3, GL_UNSIGNED_INT, vertexIndices)
        }
        
        glDisableClientState(GL_VERTEX_ARRAY)
        glDisableClientState(GL_TEXTURE_COORD_ARRAY)
        glDisable(GL_TEXTURE_2D)
        glDisable(GL_CULL_FACE)
        
    }

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


















