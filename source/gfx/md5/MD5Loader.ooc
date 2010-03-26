import io/[File, FileReader]
import MD5Model

main: func {
    
    MD5Loader new() load("../../../data/models/hophop.md5mesh")
    
}

MD5Loader: class {
    
    maxVerts := 0
    maxTris := 0

    /// Load an MD5 model from file.
    load: func (filename: String) -> MD5Model* {
        mdl: MD5Model* = gc_malloc(MD5Model size)
        //buff: Char[512]
        version: Int
        currMesh := 0
        i: Int
        
        fR := FileReader new(filename, "rb")
        
        while(fR hasNext()) {
            // Read whole line
            //fR read(buff, 0, buff length())
            buff := fR readLine()
            
            printf("# %s\n", buff)

            if (sscanf(buff, " MD5Version %d", version&) == 1) {
                if (version != 10) {
                    // Bad version
                    fprintf (stderr, "Error: bad model version\n")
                    fR close()
                    return null
                }
                printf("version = %d\n", version)
            } else if (sscanf (buff, " numJoints %d", mdl@ numJoints&) == 1) {
                printf("numJoints = %d\n", mdl@ numJoints)
                if (mdl@ numJoints > 0) {
                    // Allocate memory for base skeleton joints
                    mdl@ baseSkel = gc_malloc (mdl@ numJoints * MD5Joint size)
                }
            } else if (sscanf (buff, " numMeshes %d", mdl@ numMeshes&) == 1) {
                printf("numMeshes = %d\n", mdl@ numMeshes)
                if (mdl@ numMeshes > 0) {
                    // Allocate memory for meshes
                    mdl@ meshes = gc_malloc (mdl@ numMeshes * MD5Mesh size)
                }
            } else if (strncmp (buff, "joints {", 8) == 0) {
                // Read each joint
                for(i in 0..(mdl@ numJoints)) {
                    joint := mdl@ baseSkel[i]&

                    // Read whole line
                    fR read(buff, 0, buff length())

                    if (sscanf (buff, "%s %d ( %f %f %f ) ( %f %f %f )",
                      joint@ name, joint@ parent&, joint@ pos x&,
                      joint@ pos y&, joint@ pos z&, joint@ orient x&,
                      joint@ orient y&, joint@ orient z&) == 8) {
                        // Compute the w component
                        joint@ orient computeW()
                    }
                }
            } else if (strncmp (buff, "mesh {", 6) == 0) {
                mesh := mdl@ meshes[currMesh]&
                vertIndex := 0
                triIndex := 0
                weightIndex := 0
                fdata: Float[4]
                idata: Int[4]

                while ((buff[0] != '}') && fR hasNext()) {
                    // Read whole line
                    fR read(buff, 0, buff length())

                    if (strstr (buff, "shader ")) {
                        quote := 0; j := 0

                        // Copy the shader name whithout the quote marks 
                        i := 0
                        while(i < buff length() && (quote < 2)) {
                            if (buff[i] == '"')
                                quote += 1

                            if ((quote == 1) && (buff[i] != '"')) {
                              mesh@ shader[j] = buff[i]
                              j += 1
                            }
                            i += 1
                        }
                    } else if (sscanf (buff, " numverts %d", mesh@ numVerts&) == 1) {
                        if (mesh@ numVerts > 0) {
                            // Allocate memory for vertices 
                            mesh@ vertices = gc_malloc(MD5Vertex size * mesh@ numVerts)
                        }

                        if (mesh@ numVerts > maxVerts)
                            maxVerts = mesh@ numVerts
                    } else if (sscanf (buff, " numtris %d", mesh@ numTris&) == 1) {
                        if (mesh@ numTris > 0) {
                            // Allocate memory for triangles 
                            mesh@ triangles = gc_malloc (MD5Triangle size * mesh@ numTris)
                        }

                        if (mesh@ numTris > maxTris)
                            maxTris = mesh@ numTris
                    } else if (sscanf (buff, " numweights %d", mesh@ numWeights&) == 1) {
                        if (mesh@ numWeights > 0) {
                            // Allocate memory for vertex weights 
                            mesh@ weights = gc_malloc(MD5Weight size * mesh@ numWeights)
                        }
                    } else if (sscanf (buff, " vert %d ( %f %f ) %d %d", vertIndex&,
                       fdata[0]&, fdata[1]&, idata[0]&, idata[1]&) == 5) {
                        // Copy vertex data 
                        mesh@ vertices[vertIndex] st x = fdata[0]
                        mesh@ vertices[vertIndex] st y = fdata[1]
                        mesh@ vertices[vertIndex] start = idata[0]
                        mesh@ vertices[vertIndex] count = idata[1]
                    } else if (sscanf (buff, " tri %d %d %d %d", triIndex&,
                               idata[0]&, idata[1]&, idata[2]&) == 4) {
                        // Copy triangle data 
                        mesh@ triangles[triIndex ] index[0] = idata[0]
                        mesh@ triangles[triIndex ] index[1] = idata[1]
                        mesh@ triangles[triIndex ] index[2] = idata[2]
                    } else if (sscanf (buff, " weight %d %d %f ( %f %f %f )",
                               weightIndex&, idata[0]&, fdata[3]&,
                               fdata[0]&, fdata[1]&, fdata[2]&) == 6) {
                        // Copy vertex data 
                        mesh@ weights[weightIndex] joint  = idata[0]
                        mesh@ weights[weightIndex] bias   = fdata[3]
                        mesh@ weights[weightIndex] pos x = fdata[0]
                        mesh@ weights[weightIndex] pos y = fdata[1]
                        mesh@ weights[weightIndex] pos z = fdata[2]
                    }
                }
                currMesh += 1
            }
        }

        printf("[%s] Finished loading %s, got %d meshes, %d joints\n", class name, filename, mdl@ numMeshes, mdl@ numJoints)

        fR close()
        return mdl
    }

}
