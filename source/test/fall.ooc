import engine/[Engine, Entity, Property, Update, EventMapper, Message, Types]
import gfx/[RenderWindow, Cube, Scene, Grid, Line]
import gfx/md5/MD5Loader
import gfx/r2m/R2MLoader
import physics/[PhysicsEngine, Body, Force, Geometry, AABB]
import structs/ArrayList

import text/StringTokenizer
import console/[Console, Command]

main: func (argc: Int, argv: String*) {
	
	engine := Engine new()
	
    //--------------- Setup the window
	win := RenderWindow new(1024, 768, 32, false, "fall test")
	engine addEntity(win)
    engine addEntity(EventMapper new())
	
	//--------------- Setup the physic simulation
	physx := PhysicsEngine new()
	physx addForce(Gravity new())
    physx set("speed", 1.0)
    engine addEntity(physx)
	
    //--------------- Add a few cubes
	cubebody1 := Body new("cube_1_body") .setFixed(true)
    cubebody2 := Body new("cube_2_body") .setPos(0, 0, 20)
    physx add(cubebody1)
    physx add(cubebody2, MD5Loader new() load("data/models/ogro/ogro.md5mesh"))

    cubebody1 setGeometry(AABB new("cube_1_aabb", 1, 1, 1))
    cubebody2 setGeometry(AABB new("cube_2_aabb", 3.83 / 2.0, 2.571 / 2.0, 5.295 / 2.0))
	
    path := argc >= 2 ? argv[1] : "data/maps/ground1.r2m"
    engine addEntity(R2MLoader new() load(path))
    
    engine getEntity("console", Console) addCommand(Command new("spawn", "Spawn a new entity", func (console: Console, st: StringTokenizer) {
        console cprintln("Spawwwnniiiing!")
    }))
    
    //--------------- Start the engine!
	engine run()
}
