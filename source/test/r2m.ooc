import engine/[Engine, Entity, Property, Update, EventMapper, Message, GLConsole, Types]
import gfx/[RenderWindow, Cube, Scene, Grid]
import gfx/md5/MD5Loader
import gfx/r2m/R2MLoader
import physics/[PhysicsEngine, Body]

main: func (argc: Int, argv: String*) {
	
	engine := Engine new()
	
	win := RenderWindow new(1200, 800, 32, false, "render_window")
	win listen(QuitMessage, RenderWindow quit)
	//win listen(QuitMessage, |m| win quit())
	
	//---------------------
	physx := PhysicsEngine new()
	cube := Cube new("cube_1") .setPos(0,0,10)
	
	physx bind(cube,Body new("cube_1_body"))
	engine addEntity(cube)
	//-------------------
	
	//engine addSpawnable("m_cube",Cube new)
	//engine spawn("m_cube","cube_2",Float3 new(0,0,0))
	
    engine addEntity(GLConsole new("console"))
	
    path := argc >= 2 ? argv[1] : "data/maps/square.r2m"
   // engine addEntity(R2MLoader new() load(path))
	engine addEntity(Grid new("grid_1"))
    
	engine addEntity(EventMapper new())
	engine addEntity(win)
	engine addEntity(physx)
    
	engine run()
}
