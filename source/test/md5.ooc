import engine/[Engine, Entity, Property, Update, EventMapper, Message, GLConsole]
import gfx/[RenderWindow, Cube, Scene, Grid]
import gfx/md5/[MD5Loader]

main: func (argc: Int, argv: String*) {
	
	engine := Engine new()
	
	win := RenderWindow new(800, 600, 32, false, "md5 test")
    engine addEntity(EventMapper new())
    engine addEntity(win)
    
    path := argc >= 2 ? argv[1] : "data/models/ogro/ogro.md5mesh"
	engine addEntity(MD5Loader new() load(path))
	engine addEntity(Grid new("grid_1"))
    
	engine run()
    
}
