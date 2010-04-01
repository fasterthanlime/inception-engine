use glew
import glew
import engine/[Engine,Entity, Update, Types]
import gfx/[StaticMesh, Scene]
import console/Console

Model: abstract class extends Entity {
    
	mesh : StaticMesh
	pos := Float3 new()
	rot := Float3 new()
	
	sprogram : GLuint = 0
	timeid : Int = 0
	
	show := true
	
	init: func ~model (.name) {
		super(name)
		set("position", pos)
		set("rotation", rot)
	}
	
	setProgram: func(=sprogram) {
		timeid = glGetUniformLocation(sprogram,"time")
	}
	
	setPos: func(x,y,z: Float) {
		pos set(x,y,z)
	}
	
	_render: func {
		if(!show)
			return
		if(sprogram > 0) {glUseProgram(sprogram) ; glUniform1f(timeid,engine getTicks() as Float)}
			
		
		glPushMatrix()
		glTranslated(pos x, pos y, pos z)
		
		render()
		glPopMatrix()
        
		if(sprogram > 0) glUseProgram(0)
	}
	
	render: abstract func {}
	
	onAdd: func {
		engine scene models put(name,this)
	}
}
