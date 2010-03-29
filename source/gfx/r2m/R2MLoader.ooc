import io/[File, FileReader]
import R2MModel
import engine/Types

R2MLoader: class {

    MAX_VERSION_SUPPORTED := 1
    
    load: func (filename: String) -> R2MModel {
        
        mdl := R2MModel new(File new(filename) name(), filename)
        fR := FileReader new(filename, "rb")
        
        version: Int
        
        while(fR hasNext()) {
            
            // Read whole line
            buff := fR readLine()
            
            if (sscanf(buff, " MD5Version %d", version&) == 1) {
                if (version > MAX_VERSION_SUPPORTED) {
                    // Bad version
                    fprintf (stderr, "%s Error: bad model version %d, we only support up to %d\n" format(class name, version, MAX_VERSION_SUPPORTED))
                    fR close()
                    return null
                }
            } if(buff startsWith("things {")) {
                
                while(buff[0] != '}' && fR hasNext()) {
                    
                    buff = fR readLine()
                    
                    name := String new(256)
                    pos := Float3 new(0, 0, 0)
                    
                    if(sscanf(buff, " %s ( %f %f %f )", name, pos x&, pos y&, pos z&) == 4) {
                        mdl addThing(R2MThing new(name, pos))
                    }
                    
                }
                
            } else if(buff startsWith("models {")) {
                
                name := String new(256)
                path := String new(1024)
                
                while(buff[0] != '}' && fR hasNext()) {
                    
                    buff = fR readLine()
                    
                    if(sscanf(buff, " %s %s", name, path) == 2) {
                        mdl addModel(name clone(), "data/models/" + path)
                    }
                    
                }
                
            }
            
        }
        
        return mdl
        
    }
    
}
