import engine/[Entity, Types]
import Geometry

AABB: class extends Geometry {
    
    init: func ~aabb (.name, x, y, z: Float) {
        super(name)
        set("scale", Float3 new(x, y, z))
    }
    
    /**
       :param reaction:
       :return: true if a collision happened
     */
    collide: func (g: Geometry, reaction: Float3) -> Bool {
        
        if(!g instanceOf(This)) return false
        
        reaction x = reaction y = reaction z = 0
        
        pos1   := get("position", Float3)
        scale1 := get("scale",    Float3)
        
        pos2   := g get("position", Float3)
        scale2 := g get("scale",    Float3)
        
        if(pos1 z > pos2 z) {
            diffz1 := (pos2 z + scale2 z) - (pos1 z - scale1 z)
            if(diffz1 > 0) {
                reaction z = diffz1
                return true
            }
        }
        
        // TODO: fill
        
    }
    
}
