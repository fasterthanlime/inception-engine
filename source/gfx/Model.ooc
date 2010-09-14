use glew
import glew
import engine/[Engine,Entity, Update, Types]
import gfx/[StaticMesh, Scene, ShaderProgram]
import console/Console

Model: abstract class extends Entity {
    
	mesh : StaticMesh
	pos := Float3 new()
	rot := Float3 new()
	
	shader: ShaderProgram
	timeid: Int = 0
	
	show := true
	
	init: func ~model (.name) {
		super(name)
		set("position", pos)
		set("rotation", rot)
	}
	
	setProgram: func(=shader) {
		timeid = glGetUniformLocation(shader id, "time" toCString())
	}
	
	setPos: func(x,y,z: Float) {
		pos set(x,y,z)
	}
	
	_render: func {
		if(!show)
			return
            
		if(shader) {
            glUseProgram(shader id)
            glUniform1f(timeid, engine getTicks() as Float)
        }
			
		
		glPushMatrix()
		glTranslated(pos x, pos y, pos z)
		
		render()
		glPopMatrix()
        
		if(shader) {
            glUseProgram(0)
        }
	}
	
	render: abstract func {}
	
	onAdd: func {
		engine scene addModel(this)
	}
}
