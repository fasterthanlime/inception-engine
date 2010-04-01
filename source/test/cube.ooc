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
	engine addEntity(Console new(10, 10, 1280 * 2/5, 800 * 2/5))
	engine addEntity(Window new("window1",60,60,100,100))
	/*
	hud1 add(Window new("window1",60,60,100,100))
	hud1 add(Console new(10, 10, width * 2/5, height * 2/5))
	*/
	
	
	engine addEntity(Cube new("cube_1"))
	engine addEntity(Grid new("grid_1"))
	

	engine run()
}
