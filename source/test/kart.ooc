import engine/[Engine, Entity, Property, Update, EventMapper, Message, Types]
import gfx/[RenderWindow, Cube, Scene, Quad, Line, Camera, Texture]
import gfx/md5/MD5Loader
import gfx/r2m/R2MLoader
import sdl/[Sdl, Event]
import math

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
    cam: Camera

    alpha := 0.0

    turnLeft := false
    turnRight := false
    accelerate := false
    brake := false

    init: func {
        super("kart")

        listen(KeyboardMsg, |_m|
            m := _m as KeyboardMsg

            if(m type != SDL_KEYUP && m type != SDL_KEYDOWN) return

            val := (m type == SDL_KEYDOWN)
            match(m key) {
                case SDLK_UP    => accelerate = val
                case SDLK_DOWN  => brake      = val
                case SDLK_LEFT  => turnLeft   = val
                case SDLK_RIGHT => turnRight  = val
            }
        )
    }

    update: func {
        super()

        model pos set(-80, -80, 0.0)

        if(turnLeft) {
            alpha += 2.0
        } else if(turnRight) {
            alpha -= 2.0
        }

        if(alpha < 0)     alpha += 360.0
        if(alpha > 360.0) alpha -= 360.0
        
        model rot set(0.0, 0.0, alpha - 90)

        cameraDistance := 40
        cameraHeight := 30
        
        cam get("pos", Float3) set(
            model pos x - cos(alpha * PI / 180.0) * cameraDistance,
            model pos y - sin(alpha * PI / 180.0) * cameraDistance,
            cameraHeight
        )

        cam theta = alpha
        cam phi = -25
        cam vectorsFromAngles()
    }
    
    onAdd: func {
        engine scene addModel(model)
        cam = engine getEntity("default_cam") as Camera
    }

}


