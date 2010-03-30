use glew
import glew
import engine/[Engine,Entity, Update, Types, GLConsole]
import gfx/[StaticMesh, Scene]

Model: class extends Entity {
	mesh : StaticMesh
	pos := Float3 new(0,0,0)
	rot := Float3 new(0,0,0)
	
	show := true
	
	init: func ~model (.name) {
		super(name)
	}
	
	setPos: func(x,y,z: Float) {
		pos set(x,y,z)
	}
	
	_render: func {
		if(!show)
			return
		glPushMatrix()
		glTranslated(pos x, pos y, pos z)
		//printf("[%s]: glTranslated(%.1f, %.1f, %.1f)\n",m name,m pos x, m pos y, m pos z)
		//printf("[%s]: Rendering...\n",name)
		
		render()
		glPopMatrix()
	}
	
	render: abstract func{}
	
	onAdd: func {
		engine scene models add(this)
	}
	
}
