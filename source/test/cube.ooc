use glew
import glew
import engine/[Engine, Entity, Property, Update, EventMapper, Message,GLConsole]
import gfx/[RenderWindow, Cube, Scene, Grid, Camera]


main: func {
	
	engine := Engine new()
	
	win := RenderWindow new(1280, 800, 32, false, "render_window")
	engine addEntity(win)
	
	
	engine scene addShader("pshader_1","data/shaders/test.vert",GL_FRAGMENT_SHADER)
	engine scene createProgram("prog_1","pshader_1",null)
	engine addEntity(Cube new("cube_1"))
	engine addEntity(Grid new("grid_1"))
	
	
	engine addEntity(EventMapper new())
	

	engine run()
}
