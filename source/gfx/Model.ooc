use glew
import glew
import engine/[Engine,Entity, Update, Types]
import gfx/[StaticMesh, Scene]

Model: class extends Entity {
	mesh : StaticMesh
	pos := Float3 new(0,0,0)
	rot := Float3 new(0,0,0)
	
	init: func ~model (.name) {
		super(name)
		addUpdate(Update new(func (m : Model) -> Bool {
			glPushMatrix()
			glTranslated(m pos x, m pos y, m pos z)
			printf("[%s]: glTranslated(%.1f, %.1f, %.1f)\n",m name,m pos x, m pos y, m pos z)
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
