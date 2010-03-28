import engine/[Engine, Entity, Property, Update,QuitMessage, EventMapper, Message,GLConsole]
import gfx/[RenderWindow, Cube, Scene, Grid, Camera]


main: func {
	
	engine := Engine new()
	
	win := RenderWindow new(800, 600, 32, false, "render_window")
	win listen(QuitMessage, RenderWindow quit)
	//win listen(QuitMessage, |m| win quit())
	
	scene := Scene new("scene_1")
	console := GLConsole new~glc("console_1")
	
	scene models add(Cube new("cube_1"))
	scene models add(Grid new("grid_1"))
	scene models add(console)
	
	engine addEntity(EventMapper new())
	engine addEntity(scene)
	engine addEntity(win)
	engine addEntity(console)
	engine run()
}
