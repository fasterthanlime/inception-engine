import engine/[Engine, Entity, Property, Update,QuitMessage, EventMapper, Message]
import gfx/[RenderWindow, Cube, Scene]


main: func {
	
	engine := Engine new()
	
	win := RenderWindow new(800, 600, 32, false, "render_window")
	win listen(QuitMessage, RenderWindow quit)
	//win listen(QuitMessage, |m| win quit())
	
	scene := Scene new("scene_1")
	
	
	cube := Cube new("cube_1")
	scene models add(cube)
	
	engine addEntity(EventMapper new())
	engine addEntity(scene)
	engine addEntity(win)
	engine run()
}
