import engine/[Entity, Types]
import Geometry

/**
 * @deprecated
 */
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
        
        if(!g instanceOf?(This)) return false
        
        reaction x = reaction y = reaction z = 0
        
        pos1   := get("position", Float3)
        scale1 := get("scale",    Float3)
        
        pos2   := g get("position", Float3)
        scale2 := g get("scale",    Float3)
        
        plusDiffx  := (pos2 x + scale2 x) - (pos1 x - scale1 x)
        if(plusDiffx < 0) return false
    
        plusDiffy  := (pos2 y + scale2 y) - (pos1 y - scale1 y)
        if(plusDiffy < 0) return false
        
        plusDiffz  := (pos2 z + scale2 z) - (pos1 z - scale1 z)
        if(plusDiffz < 0) return false
        
        minusDiffx := (pos2 x - scale2 x) - (pos1 x + scale1 x)
        if(minusDiffx > 0) return false
        
        minusDiffy := (pos2 y - scale2 y) - (pos1 y + scale1 y)
        if(minusDiffy > 0) return false
        
        minusDiffz := (pos2 z - scale2 z) - (pos1 z + scale1 z)
        if(minusDiffy > 0) return false
                
        if(pos1 z > pos2 z) {
            reaction z = (pos1 z > pos2 z) ? plusDiffz : minusDiffz
            return true
        }
        
        // TODO: fill
        false
        
    }
    
}
