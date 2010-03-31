import engine/[Engine, Entity, Property, Update, EventMapper, Message, GLConsole, Types]
import gfx/[RenderWindow, Cube, Scene, Grid, Line]
import gfx/md5/MD5Loader
import gfx/r2m/R2MLoader
import physics/[PhysicsEngine, Body, Force, Geometry, AABB]
import structs/ArrayList

main: func (argc: Int, argv: String*) {
	
	engine := Engine new()
	
    //--------------- Setup the window
	win := RenderWindow new(800, 600, 32, false, "fall test")
	engine addEntity(win)
    engine addEntity(EventMapper new())
	
	//--------------- Setup the physic simulation
	physx := PhysicsEngine new()
	physx addForce(Gravity new())
    physx set("speed", 1.0)
    engine addEntity(physx)
	
    //--------------- Add a few cubes
	cubebody1 := Body new("cube_1_body") .setFixed(true)
    cubebody2 := Body new("cube_2_body") .setPos(0, 0, 15)
    physx add(cubebody1)
    physx add(cubebody2, Cube new("cube_2"))

    cubebody1 setGeometry(AABB new("cube_1_aabb", 1, 1, 1))
    cubebody2 setGeometry(AABB new("cube_2_aabb", 1, 1, 1))
	
    path := argc >= 2 ? argv[1] : "data/maps/square.r2m"
    engine addEntity(R2MLoader new() load(path))
	engine addEntity(Grid new("grid_1"))
    
    //--------------- Start the engine!
	engine run()
}
