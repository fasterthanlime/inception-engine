import engine/[Engine, Entity, Property, Update, EventMapper, Message, Types]
import gfx/[RenderWindow, Cube, Scene, Quad, Line, Camera, Texture]
import gfx/md5/MD5Loader
import gfx/r2m/R2MLoader
import sdl/Event

import text/StringTokenizer
import console/[Console, Command]
import hud/[Hud, Window, ConvertCoords, FPSCounter]

main: func (argc: Int, argv: Char*) {
	
	engine := Engine new()
	
    //--------------- Setup the window
    width := 1280
    height := 1024
    
	win := RenderWindow new(width, height, 16, false, "kart test")
	engine addEntity(win)
    engine addEntity(Console new(10, 10, width * 2/5, height * 2/5))
    engine addEntity(EventMapper new())

    //--------------- Create the grid
    track := Quad new("track")
    track set("x_range", Float2 new(-300, 300))
    track set("y_range", Float2 new(-300, 300))
    track texture = Texture new("data/maps/circuit_couleur1.png")
    engine scene addModel(track)

    //--------------- Adjust the camera
    cam := engine getEntity("default_cam") as Camera
    //cam set("sensitivity", 0)
    //cam set("speed", 0)
    cam set("pos", Float3 new(40, 40, 40))
    
    //cam set("target", Float3 new(0.5, 0.5, 0))
    //cam phi = -90

    //--------------- Add our kart
    engine addEntity(Kart new())
    
    //--------------- Start the engine!
	engine run()
    
}

Kart: class extends Entity {

    model := MD5Loader load("data/models/tricycle/tricycle.md5mesh")

    init: func {
        super("kart")
        //model pos set(-80, -80, 0.0)
    }
    
    onAdd: func {
        engine scene addModel(model)
    }

}


