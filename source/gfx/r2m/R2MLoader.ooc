import io/[File, FileReader]
import R2MModel, ../Cube
import engine/Types
import math

R2MLoader: class {

    MAX_VERSION_SUPPORTED := static 2
    trackScale := 100.0
    
    load: func (filename: String) -> R2MModel {
        
        mdl := R2MModel new(File new(filename) name(), filename)
        fR := FileReader new(filename, "rb")
        
        version: Int
        
        while(fR hasNext?()) {
            
            // Read whole line
            buff := fR readLine()
            
            if (sscanf(buff toCString(), " R2MVersion %d" toCString(), version&) == 1) {
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
                        mdl addThing(R2MThing new(mdl models get(name toString()), pos))
                    }
                    
                }
                
            } if(buff startsWith?("trackbounds {")) {
                
                while(buff[0] != '}' && fR hasNext?()) {
                    buff = fR readLine()
                    
                    begin := Float3 new(0, 0, 0)
                    end := Float3 new(0, 0, 0)
                    
                    if(sscanf(buff toCString(), " ( %f %f ) ( %f %f )" toCString(), begin x&, begin y&, end x&, end y&) == 4) {
                        // shift and scale our coordinates
                        begin addSet(-0.5, -0.5, 0). scale(trackScale)
                        end   addSet(-0.5, -0.5, 0). scale(trackScale)
                        
                        diff := end - begin
                        length := diff length() * 0.5
                        
                        pos := begin + (diff * 0.5)

                        width := 2.0
                        
                        diff normalize()
                        angle := (atan2(diff y, diff x) - atan2(1, 0)) * 180.0 / PI
                        ("begin / end = " + begin toString() + " / " + end toString() + ", pos = " + pos toString() + " angle = %.2f" format(angle)) println()

                        cube := Cube new("trackbound")
                        cube set("scale", Float3 new(width, length, width))
                        
                        thing := R2MThing new(cube, pos)
                        thing rot z = angle
                        mdl addThing(thing)
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
                        mdl addModel(name clone() toString(), "data/models/" + path toString())
                    }
                    
                }
                
            }
            
        }
        
        return mdl
        
    }
    
}
