import engine/[Entity, Types]

Geometry: abstract class extends Entity {
    
    init: func ~coll (.name) {
        super(name)
        set("position", Float3 new())
    }
    
    /**
     * Check collision beetween this object and another one.
     * 
     * @param   g           other object used in test.
     * @param   reaction    reaction vector of collision, set only
     *                      if collision happened, see return.
     * @return  true if collision happened.
     */
    collide: func (g: Geometry, reaction: Float3) -> Bool {
        collisionHandler := CollisionHandlerFactory \
            getHandler(this, g)

        if (collisionHandler) {
            return collisionHandler(this, g, reaction)
        } else {
            ("No handler available for (" +
                this class name +
                ", " + 
                g class name +
                ")") \
                println()
            return false
        }
    }
    
}
