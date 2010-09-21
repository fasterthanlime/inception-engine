use glew
import glew
import engine/[Engine,Entity, Update, Types]
import gfx/[StaticMesh, Scene, ShaderProgram, Texture]
import console/Console

Model: abstract class extends Entity {
    
	mesh : StaticMesh
	pos := Float3 new()
	rot := Float3 new()

    writeDepth := true
	
	shader: ShaderProgram
	timeid: Int = 0

    texture: Texture = null
	
	show := true
    wire := false
	
	init: func ~model (.name) {
		super(name)
		set("position", pos)
		set("rotation", rot)
	}
	
	setProgram: func(=shader) {
		timeid = glGetUniformLocation(shader id, "time" toCString())
	}
	
	setPos: func(x, y, z: Float) {
		pos set(x, y, z)
	}
	
	_render: func {
		if(!show)
			return // don't render hidden objects

        /*
		if(shader) {
            glUseProgram(shader id)
            glUniform1f(timeid, engine getTicks() as Float)
        }
        */
        if(texture) texture enable()
        /*
        if(!writeDepth) glDepthMask(false)
        if(wire) glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
        */
		
		glPushMatrix()
            glTranslated(pos x, pos y, pos z)
            glRotated(rot z, 0, 0, 1)
            render()
		glPopMatrix()

        /*
        if(wire) glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
        if(!writeDepth) glDepthMask(true)
        */
        if(texture) texture disable()
		//if(shader) glUseProgram(0)
	}
	
	render: abstract func {}
	
	onAdd: func {
		engine scene addModel(this)
	}
}
