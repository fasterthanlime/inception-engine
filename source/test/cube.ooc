use glew
import glew
import engine/[Engine, Entity, Property, Update, EventMapper, Message,GLConsole]
import gfx/[RenderWindow, Cube, Scene, Grid, Camera]


main: func {
	
	engine := Engine new()
	
	win := RenderWindow new(1280, 800, 32, false, "render_window")
	
	//engine scene addShader("shader_1","data/shaders/shader1.vert",GL_FRAGMENT_SHADER)
	console := GLConsole new~glc("console_1")
	
	engine addEntity(Cube new("cube_1"))
	engine addEntity(Grid new("grid_1"))
	engine addEntity(console)
	
	
	engine addEntity(EventMapper new())
	engine addEntity(win)

	engine run()
}
