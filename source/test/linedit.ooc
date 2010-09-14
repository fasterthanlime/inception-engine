import engine/[Engine, Entity, Property, Update, EventMapper, Message, Types]
import gfx/[RenderWindow, Cube, Scene, Grid, Line, Camera]
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
    
	win := RenderWindow new(width, height, 16, false, "fall test")
	engine addEntity(win)
    engine addEntity(Console new(10, 10, width * 2/5, height * 2/5))
    engine addEntity(EventMapper new())
    engine addEntity(ConvertCoords new())

    engine addEntity(Grid new("grid_1"))
    cam := engine getEntity("default_cam") as Camera
    cam set("sensitivity", 0)
    cam set("speed", 0)
    cam set("pos", Float3 new(0, 0, 45))
    cam set("target", Float3 new(0, 0, 0))
    cam phi = -90

    cube := Cube new("mouse_cube")
    cube set("side", 0.2)
    cube writeDepth = false
    engine getEntity("3d_coords") get("coords", Float3) bind(cube pos)
    engine scene addModel(cube)

    engine addEntity(LineTracer new())
    
    //--------------- Start the engine!
	engine run()
    
}

LineTracer: class extends Entity {

    line := Line new("mouse_line")

    init: func {
        super("line_tracer")
        line show = false

        listen(MouseMotion, |_m|
            m := _m as MouseMotion

            if(!line show) return
            
            coords := engine getEntity("3d_coords") get("coords", Float3)
            line get("end", Float3) set(coords x, coords y, 1)
        )

        listen(MouseButton, |_m|
            m := _m as MouseButton

            coords := engine getEntity("3d_coords") get("coords", Float3)
            
            match (m type) {
                case SDL_MOUSEBUTTONDOWN =>
                    line get("begin", Float3) set(coords x, coords y, 1)
                    line get("end",   Float3) set(coords x, coords y, 1)
                    line show = true
                case SDL_MOUSEBUTTONUP =>
                    line get("end", Float3) set(coords x, coords y, 1)
                    line show = false
            }
        )
    }
    
    onAdd: func {
        engine scene addModel(line)
    }

}

