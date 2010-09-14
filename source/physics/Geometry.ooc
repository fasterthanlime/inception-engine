import engine/[Entity, Types]

Geometry: abstract class extends Entity {
    
    init: func ~coll (.name) {
        super(name)
        set("position", Float3 new())
    }
    
    collide: abstract func (g: Geometry, reaction: Float3) -> Bool {}
    
}
