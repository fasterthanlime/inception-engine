use glew
import glew
import engine/[Engine,Entity, Update]
import gfx/[StaticMesh, Scene]

Model: class extends Entity {
	mesh : StaticMesh
	
	init: func ~model (.name) {
		super(name)
		addUpdate(Update new(func (m : Model) -> Bool {
			glPushMatrix()
			m render()
			glPopMatrix()
			true
		}))
	}
	
	render: abstract func {}
	
	onAdd: func {
		engine scene models add(this)
	}
	
}
