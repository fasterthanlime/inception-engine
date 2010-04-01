use glew
import glew
import engine/[Engine, Entity, Property, Update, EventMapper, Message]
import gfx/[RenderWindow, Cube, Scene, Grid, Camera]
import console/Console
import hud/[Hud,Window]

main: func {
	
	engine := Engine new()
	
	win := RenderWindow new(1280, 800, 32, false, "render_window")
	engine addEntity(win)
	engine addEntity(EventMapper new())
	
	/*
	hud1 add(Window new("window1",60,60,100,100))
	hud1 add(Console new(10, 10, width * 2/5, height * 2/5))
	*/
	
	console := engine getEntity("console",Console)
	console cprint("hello there")
	console cprint(" comment ca va,")
	console cprint(" j'espere que vui =)")
	console cprintln()
	
	//engine scene addProgram("screen_program")
	//engine scene setProgram(engine getEntity("cube_1"), "prog_1")	
	
	engine addEntity(EventMapper new())
	engine run()
}
