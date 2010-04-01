import engine/[Engine, Entity, Property, Update, EventMapper, Message, GLConsole, Types]
import gfx/[RenderWindow, Cube, Scene, Grid, Line]
import gfx/md5/MD5Loader
import gfx/r2m/R2MLoader
import physics/[PhysicsEngine, Body, Force]
import structs/ArrayList

main: func (argc: Int, argv: String*) {
	
	engine := Engine new()
	
	win := RenderWindow new(1200, 800, 32, false, "render_window")
	engine addEntity(win)
    engine addEntity(EventMapper new())
    
	engine addEntity(Grid new("grid_1"))
    path := argc >= 2 ? argv[1] : "data/maps/square.r2m"
    engine addEntity(R2MLoader new() load(path))
    
	engine run()
}
