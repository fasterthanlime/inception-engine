import engine/[Engine, Entity, Property, Update, EventMapper, Message, Types]
import gfx/[RenderWindow, Cube, Scene, Quad, Line, Camera, Texture]
import physics/PhysicsEngine

import text/StringTokenizer
import console/[Console, Command]
import hud/[Hud, Window, ConvertCoords, FPSCounter]

import gameplay/Kart

main: func (argc: Int, argv: Char*) {
	
	engine := Engine new()
	
    //--------------- Setup the window
    width := 1280
    height := 1024
	win := RenderWindow new(width, height, 16, false, "kart test")
	engine addEntity(win)

    //--------------- Create the ingame console
    engine addEntity(Console new(10, 10, width * 2/5, height * 2/5))

    //--------------- Set up the keyboard / mouse input
    engine addEntity(EventMapper new())

    //--------------- Set up the physics engine
    engine addEntity(PhysicsEngine new())

    //--------------- Load the track
    track := Quad new("track")
    track set("x_range", Float2 new(-300, 300))
    track set("y_range", Float2 new(-300, 300))
    track texture = Texture new("data/maps/circuit_couleur1.png")
    engine scene addModel(track)

    //--------------- Add our kart
    engine addEntity(Kart new())
    
    //--------------- Start the engine!
	engine run()
    
}

