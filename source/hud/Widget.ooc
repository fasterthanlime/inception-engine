use glew
import glew

import engine/[Types, Entity]

Widget: class extends Entity {

    show := true

    init: func (.name) {
        super(name)
        set("position", Float3 new(0, 0, 0))
    }

    render: func {
		if(!show) return
            
		pos := get("position", Float3)
		glTranslated(pos x, pos y, 0)
        wRender()
	}
	
	wRender: func {}

    onAdd: func {
		engine getHud() add(this)
	}

}
