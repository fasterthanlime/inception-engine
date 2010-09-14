import io/[File, FileReader]
import R2MModel
import engine/Types

R2MLoader: class {

    MAX_VERSION_SUPPORTED := 1
    
    load: func (filename: String) -> R2MModel {
        
        mdl := R2MModel new(File new(filename) name(), filename)
        fR := FileReader new(filename, "rb")
        
        version: Int
        
        while(fR hasNext?()) {
            
            // Read whole line
            buff := fR readLine()
            
            if (sscanf(buff toCString(), " MD5Version %d" toCString(), version&) == 1) {
                if (version > MAX_VERSION_SUPPORTED) {
                    // Bad version
                    fprintf (stderr, "%s Error: bad model version %d, we only support up to %d\n" format(class name, version, MAX_VERSION_SUPPORTED))
                    fR close()
                    return null
                }
            } if(buff startsWith?("things {")) {
                
                while(buff[0] != '}' && fR hasNext?()) {
                    
                    buff = fR readLine()
                    
                    name := Buffer new(256)
                    pos := Float3 new(0, 0, 0)
                    
                    if(sscanf(buff toCString(), " %s ( %f %f %f )" toCString(), name data, pos x&, pos y&, pos z&) == 4) {
                        name sizeFromData()
                        mdl addThing(R2MThing new(name toString(), pos))
                    }
                    
                }
                
            } else if(buff startsWith?("models {")) {
                
                name := Buffer new(256)
                path := Buffer new(1024)
                
                while(buff[0] != '}' && fR hasNext?()) {
                    
                    buff = fR readLine()
                    
                    if(sscanf(buff toCString(), " %s %s" toCString(), name data, path data) == 2) {
                        path sizeFromData()
                        name sizeFromData()
                        ("Read path name = " + path toString()) println()
                        mdl addModel(name clone() toString(), "data/models/" + path toString())
                    }
                    
                }
                
            }
            
        }
        
        return mdl
        
    }
    
}
