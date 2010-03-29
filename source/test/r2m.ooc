import engine/[Engine, Entity, Property, Update, EventMapper, Message, GLConsole, Types]
import gfx/[RenderWindow, Cube, Scene, Grid]
import gfx/md5/MD5Loader
import gfx/r2m/R2MLoader

main: func (argc: Int, argv: String*) {
	
	engine := Engine new()
	
	win := RenderWindow new(1680, 1050, 32, false, "render_window")
	win listen(QuitMessage, RenderWindow quit)
	//win listen(QuitMessage, |m| win quit())
	
	scene := Scene new("gamescene")
    
    console := GLConsole new("console")
    scene models add(console)
    engine addEntity(console)
	
    path := argc >= 2 ? argv[1] : "data/maps/square.r2m"
	scene models add(R2MLoader new() load(path))
	scene models add(Grid new("grid_1"))
    
	engine addEntity(EventMapper new())
	engine addEntity(scene)
	engine addEntity(win)
    
	engine run()
}
