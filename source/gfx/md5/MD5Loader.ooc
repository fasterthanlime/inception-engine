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

import io/[File, FileReader]
import structs/HashMap
import MD5Model

MD5Loader: class {
    
    cache := static HashMap<String, MD5Model> new()
    
    /// Load an MD5 model from file.
    load: static func (filename: String) -> MD5Model {
        
        cached := This cache get(filename)
        if(cached != null) return cached clone()
        
        mdl := MD5Model new(filename)
        version: Int
        currMesh := 0
        i: Int

        ("Loading md5 model " + filename) println()
        fR := FileReader new(filename, "rb")
        
        while(fR hasNext?()) {
            // Read whole line
            buff := fR readLine()
            
            if (sscanf(buff toCString(), " MD5Version %d", version&) == 1) {
                if (version != 10) {
                    // Bad version
                    fprintf (stderr, "%s Error: bad model version %d, we only support 10\n" format(This name, version))
                    fR close()
                    return null
                }
            } else if (sscanf (buff toCString(), " numJoints %d", mdl numJoints&) == 1) {
                if (mdl numJoints > 0) {                    
                    // Allocate memory for base skeleton joints
                    mdl baseSkel = gc_malloc (mdl numJoints * MD5Joint size)
                    for(i in 0..mdl numJoints) {
                        mdl baseSkel[i] = MD5Joint new()
                    }
                }
            } else if (sscanf (buff toCString(), " numMeshes %d", mdl numMeshes&) == 1) {
                "Got %d meshes" printfln(mdl numMeshes)
                if (mdl numMeshes > 0) {
                    // Allocate memory for meshes
                    mdl meshes = gc_malloc (mdl numMeshes * MD5Mesh size)
                    for(i in 0..mdl numMeshes) {
                        mdl meshes[i] = MD5Mesh new()
                    }
                }
            } else if (strncmp (buff toCString(), "joints {", 8) == 0) {
                // Read each joint
                for(i in 0..mdl numJoints) {
                    joint := mdl baseSkel[i]

                    // Read whole line
                    buff = fR readLine()

                    if (sscanf (buff toCString(), "%s %d ( %f %f %f ) ( %f %f %f )",
                      joint name, joint parent&, joint pos x&,
                      joint pos y&, joint pos z&, joint orient x&,
                      joint orient y&, joint orient z&) == 8) {
                        // Compute the w component
                        joint orient computeW()
                    }
                }
            } else if (strncmp (buff toCString(), "mesh {", 6) == 0) {
                mesh := mdl meshes[currMesh]
                vertIndex := 0
                triIndex := 0
                weightIndex := 0
                fdata: Float[4]
                idata: Int[4]

                while ((buff size == 0 || buff[0] != '}') && fR hasNext?()) {
                    
                    // Read whole line
                    buff = fR readLine()
                    
                    if (strstr (buff toCString(), "shader ")) {
                        quote := 0; j := 0

                        // Copy the shader name whithout the quote marks 
                        i := 0
                        while(i < buff size && (quote < 2)) {
                            if (buff[i] == '"')
                                quote += 1

                            if ((quote == 1) && (buff[i] != '"')) {
                              mesh shader[j] = buff[i]
                              j += 1
                            }
                            i += 1
                        }
                    } else if (sscanf (buff toCString(), " numverts %d", mesh numVerts&) == 1) {
                        if (mesh numVerts > 0) {
                            // Allocate memory for vertices 
                            mesh vertices = gc_malloc(MD5Vertex instanceSize * mesh numVerts)
                        }

                        if (mesh numVerts > mdl maxVerts)
                            mdl maxVerts = mesh numVerts
                    } else if (sscanf (buff toCString(), " numtris %d", mesh numTris&) == 1) {
                        if (mesh numTris > 0) {
                            // Allocate memory for triangles
                            mesh triangles = gc_malloc (MD5Triangle instanceSize * mesh numTris)
                        }

                        if (mesh numTris > mdl maxTris)
                            mdl maxTris = mesh numTris
                    } else if (sscanf (buff toCString(), " numweights %d", mesh numWeights&) == 1) {
                        if (mesh numWeights > 0) {
                            // Allocate memory for vertex weights 
                            mesh weights = gc_malloc(MD5Weight instanceSize * mesh numWeights)
                        }
                    } else if (sscanf (buff toCString(), " vert %d ( %f %f ) %d %d", vertIndex&,
                       fdata[0]&, fdata[1]&, idata[0]&, idata[1]&) == 5) {
                        // Copy vertex data 
                        mesh vertices[vertIndex] st x = fdata[0]
                        mesh vertices[vertIndex] st y = 1 - fdata[1]
                        "Got UV (%.2f, %.2f)" printfln(mesh vertices[vertIndex] st x, mesh vertices[vertIndex] st y)
                        mesh vertices[vertIndex] start = idata[0]
                        mesh vertices[vertIndex] count = idata[1]
                    } else if (sscanf (buff toCString(), " tri %d %d %d %d", triIndex&,
                               idata[0]&, idata[1]&, idata[2]&) == 4) {
                        // Copy triangle data 
                        mesh triangles[triIndex ] a = idata[0]
                        mesh triangles[triIndex ] b = idata[1]
                        mesh triangles[triIndex ] c = idata[2]
                    } else if (sscanf (buff toCString(), " weight %d %d %f ( %f %f %f )",
                               weightIndex&, idata[0]&, fdata[3]&,
                               fdata[0]&, fdata[1]&, fdata[2]&) == 6) {
                        // Copy vertex data 
                        mesh weights[weightIndex] joint  = idata[0]
                        mesh weights[weightIndex] bias   = fdata[3]
                        mesh weights[weightIndex] pos x = fdata[0]
                        mesh weights[weightIndex] pos y = fdata[1]
                        mesh weights[weightIndex] pos z = fdata[2]
                    }
                }
                currMesh += 1
            }
        }

        printf("[%s] Finished loading %s, got %d meshes, %d joints\n", This name toCString(), filename toCString(), mdl numMeshes, mdl numJoints)

        mdl allocVertexArrays()

        fR close()
        
        cache put(filename, mdl)
        
        mdl prepareMesh(mdl meshes[0], mdl baseSkel)
        mdl
    }

}
