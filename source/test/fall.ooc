import engine/[Engine, Entity, Property, Update, EventMapper, Message, Types]
import gfx/[RenderWindow, Cube, Scene, Grid, Line]
import gfx/md5/MD5Loader
import gfx/r2m/R2MLoader
import physics/[PhysicsEngine, Body, Force, Geometry, AABB]
import structs/ArrayList
import math, math/Random

import text/StringTokenizer
import console/[Console, Command]
import hud/[Hud,Window,FPSCounter]

main: func (argc: Int, argv: String*) {
	
	engine := Engine new()
	
    //--------------- Setup the window
	win := RenderWindow new(1024, 768, 16, false, "fall test")
	engine addEntity(win)
    engine addEntity(Console new(10, 10, 1280 * 2/5, 800 * 2/5))
	//engine addEntity(Window new("window1",60,60,100,100))
    engine addEntity(EventMapper new())
	
	//--------------- Setup the physic simulation
	physx := PhysicsEngine new()
	physx addForce(Gravity new())
    physx set("speed", 2.0)
    engine addEntity(physx)
	
    //--------------- Add a few cubes
    path := argc >= 2 ? argv[1] : "data/maps/ground1.r2m"
    engine addEntity(R2MLoader new() load(path))
    
	groundBody := Body new("ground_body") .setFixed(true)
    groundBody setGeometry(AABB new("ground_body_aabb", 30, 30, 1))
    physx add(groundBody)
    
    console := Console
    
    engine getEntity("console", Console) addCommand(Command new("spawn", "Spawn a new entity", func (console: Console, st: StringTokenizer) {
        console cprintln("Spawwwnniiiing!")
        
        physx := console engine getEntity("physx", PhysicsEngine)
        
        ogroBody2 := Body new("ogro_body") .setPos(Random random() % 40 - 20, Random random() % 40 - 20, 20)
        ogroBody2 setGeometry(AABB new("ogro_body_aabb", 3.83 / 2.0, 2.571 / 2.0, 5.295 / 2.0))
        physx add(ogroBody2, MD5Loader load("data/models/ogro/ogro.md5mesh"))
    }))
    
    //--------------- Start the engine!
	engine run()
}
