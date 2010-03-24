import engine/Entity
import gfx/StaticMesh

Model: class extends Entity {
	mesh : StaticMesh
	
	init: func ~model (name) {
		super(name)
	}
	
	render: func {
	}
	
}
