import engine/[Engine, Entity, Property, Update,QuitMessage, EventMapper, Message, GLConsole]
import gfx/[RenderWindow, Cube, Scene, Grid]
import gfx/md5/[MD5Loader]

main: func {
	
	engine := Engine new()
	
	win := RenderWindow new(800, 600, 32, false, "render_window")
	win listen(QuitMessage, RenderWindow quit)
	//win listen(QuitMessage, |m| win quit())
	
	scene := Scene new("scene_1")
	
	scene models add(MD5Loader new() load("data/models/hophop.md5mesh"))
	scene models add(Grid new("grid_1"))
	
	engine addEntity(EventMapper new())
	engine addEntity(scene)
	engine addEntity(win)
	engine run()
}
