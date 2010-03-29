import structs/[ArrayList, HashMap]
import engine/Types, gfx/Model
import ../md5/[MD5Loader, MD5Model]

import glew

R2MThing: class {
    model: String
    pos: Float3
    
    init: func (=model, =pos) {}
}

R2MModel: class extends Model {    
    models := HashMap<String, MD5Model> new()
    things : R2MThing[]
    path: String
    
    init: func ~name (.name, =path) {
        super(name)
    }
    
    render: func {
        for(thing in things) {
            glPushMatrix()
                glTranslated(thing pos x, thing pos y, thing pos z)
                model := models get(thing model)
                model render()
            glPopMatrix()
        }
    }
    
    addThing: func (thing: R2MThing) {
        things add(thing)
    }
    
    addModel: func (name, path: String) {
        models put(name, MD5Loader new() load(path))
    }
}

