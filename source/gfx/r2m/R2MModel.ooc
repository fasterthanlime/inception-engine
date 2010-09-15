import structs/[ArrayList, HashMap]
import engine/Types, gfx/Model
import ../md5/[MD5Loader, MD5Model]

import glew

R2MThing: class {
    model: Model

    pos : Float3
    rot := Float3 new()
    
    init: func (=model, =pos) {}
}

R2MModel: class extends Model {    
    models := HashMap<String, Model> new()
    things := ArrayList<R2MThing> new()
    path: String
    
    init: func ~name (.name, =path) {
        super(name)
    }
    
    render: func {
        for(thing in things) {
            glPushMatrix()
                glTranslated(thing pos x, thing pos y, thing pos z)
                glRotated(thing rot z, 0, 0, 1)
                if(thing model) thing model render()
            glPopMatrix()
        }
    }
    
    addThing: func (thing: R2MThing) {
        things add(thing)
    }
    
    addModel: func (name, path: String) {
        models put(name, MD5Loader load(path))
    }
}

