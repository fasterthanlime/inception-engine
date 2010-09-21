import engine/[Engine, Entity, Property, Update, EventMapper, Message, Types]
import gfx/[RenderWindow, Cube, Scene, Quad, Line, Camera, Texture]
import gfx/r2m/[R2MLoader]
import physics/PhysicsEngine

import io/File
import text/StringTokenizer
import console/[Console, Command]
import hud/[Hud, Window, ConvertCoords, SpeedoMeter]

import gameplay/Kart

main: func (argc: Int, argv: CString*) {
	
	engine := Engine new()
	
    //--------------- Setup the window
    width := 1280
    height := 800
	win := RenderWindow new(width, height, 16, false, "Ice Cream Madness")
	engine addEntity(win)

    //--------------- Create the ingame console
    console := Console new(10, 10, width * 2/5, height * 2/5)
    engine addEntity(console)

    //--------------- Set up the keyboard / mouse input
    engine addEntity(EventMapper new())

    //--------------- Set up the physics engine
    engine addEntity(PhysicsEngine new())

    //--------------- Load the track
    track := Quad new("track")
    trackSide := 600.0
    track set("x_range", Float2 new(-trackSide, trackSide))
    track set("y_range", Float2 new(-trackSide, trackSide))
    track texture = Texture new("data/maps/circuit_couleur1.png")
    engine scene addModel(track)

    loader := R2MLoader new()
    loader trackScale = trackSide * 2
    level := loader load("data/maps/edited_track.r2m")
    level name = "level"
    engine addEntity(level)

    //--------------- Add our kart
    kart := Kart new()
    kart body get("position", Float3) set(-500, 350, 0)
    engine addEntity(kart)

    //--------------- Add the speedometer
    engine addEntity(SpeedoMeter new(kart))
    
    //--------------- Load and interpret the autoexec.cfg file
    autoPath := "autoexec.cfg"
    if(File new(autoPath) exists?()) {
		"Loading script file '" + autoPath + "'"
		console load(autoPath)
	}
    
    //--------------- Start the engine!
	engine run()
    
}

