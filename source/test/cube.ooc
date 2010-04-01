use glew
import glew
import engine/[Engine, Entity, Property, Update, EventMapper, Message]
import gfx/[RenderWindow, Cube, Scene, Grid, Camera]


main: func {
	
	engine := Engine new()
	
	win := RenderWindow new(1280, 800, 32, false, "render_window")
	engine addEntity(win)
	engine addEntity(EventMapper new())
	
	engine addEntity(Cube new("cube_1"))
	engine addEntity(Grid new("grid_1"))
	
	engine scene addShader("vshader_1", "data/shaders/test.vert", GL_VERTEX_SHADER)
	engine scene addShader("pshader_1", "data/shaders/test.frag", GL_FRAGMENT_SHADER)
	engine scene addShader("empty", "data/shaders/empty.vert", GL_VERTEX_SHADER)
	
	engine scene addShader("phong_v", "data/shaders/phong.vert", GL_VERTEX_SHADER)
	engine scene addShader("phong_p", "data/shaders/phong.frag", GL_FRAGMENT_SHADER)
	
	engine scene createProgram("phong","phong_p","phong_v")
	
	engine scene createProgram("prog_1", null, "vshader_1")

	engine scene createProgram("screen_program","pshader_1","empty")
	
	engine scene addProgram("screen_program")
	engine scene setProgram("cube_1", "prog_1")	
	
	engine addEntity(EventMapper new())
	

	engine run()
}
