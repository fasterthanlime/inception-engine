import engine/[Entity, Update]
import gfx/StaticMesh

Model: class extends Entity {
	mesh : StaticMesh
	
	init: func ~model (.name) {
		super(name)
		addUpdate(Update new(func (m : Model) -> Bool {
			m render(); true
		}))
	}
	
	render: abstract func {}
	
}
