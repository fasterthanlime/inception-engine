import engine/[Engine, Entity, Property, Update, EventMapper, Message, Types]
import gfx/[RenderWindow, Cube, Scene, Quad, Line, Camera, Texture]
import gfx/md5/MD5Loader
import gfx/r2m/R2MLoader
import sdl/Event

import text/StringTokenizer
import console/[Console, Command]
import hud/[Hud, Window, ConvertCoords]

import structs/ArrayList
import io/FileWriter

main: func (argc: Int, argv: CString*) {
	
	engine := Engine new()
	
    //--------------- Setup the window
    width := 1280
    height := 1024
    
	win := RenderWindow new(width, height, 32, false, "Ice Cream Madness [Track Editor]")
	engine addEntity(win)
    engine addEntity(Console new(10, 10, width * 2/5, height * 2/5))
    engine addEntity(EventMapper new())
    engine addEntity(ConvertCoords new())

    //--------------- Create the grid
    track := Quad new("track")
    track set("x_range", Float2 new(0, 1))
    track set("y_range", Float2 new(0, 1))
    track texture = Texture new("data/maps/circuit_couleur1.png")
    engine scene addModel(track)

    //--------------- Adjust the camera
    cam := engine getEntity("default_cam") as Camera
    cam set("sensitivity", 0)
    cam set("speed", 0)
    cam set("position", Float3 new(0.5, 0.5, 2.0))
    cam set("target", Float3 new(0.5, 0.5, 0))
    cam phi = -90

    //--------------- Create a mouse pointer
    pointer := Quad new("mouse_pointer")
    pointer set("x_range", Float2 new(-0.02, 0.02))
    pointer set("y_range", Float2 new(-0.02, 0.02))
    pointer texture = Texture new("data/images/crosshair.png")
    pointer writeDepth = false
    engine getEntity("3d_coords") get("coords", Float3) bind(pointer pos)
    engine scene addModel(pointer)

    //--------------- Add our line tracer
    engine addEntity(LineTracer new())
    
    //--------------- Start the engine!
	engine run()
    
}

LineTracer: class extends Entity {

    line := Line new("mouse_line")
    lines := ArrayList<Line> new()

    init: func {
        super("line_tracer")
        line show = false

        listen(MouseMotion, |_m|
            m := _m as MouseMotion

            if(!line show) return
            
            coords := engine getEntity("3d_coords") get("coords", Float3)
            line get("end", Float3) set(coords)
        )

        listen(MouseButton, |_m|
            m := _m as MouseButton

            coords := engine getEntity("3d_coords") get("coords", Float3)
            
            match (m type) {
                case SDL_MOUSEBUTTONDOWN =>
                    line get("begin", Float3) set(coords)
                    line get("end",   Float3) set(coords)
                    line show = true
                case SDL_MOUSEBUTTONUP =>
                    line get("end", Float3) set(coords)
                    line show = false

                    newLine := Line new(
                        "lineDrawn",
                        line get("begin", Float3) clone(),
                        line get("end",   Float3) clone()
                    )
                    lines add(newLine)
                    engine scene addModel(newLine)
            }
        )

        listen(KeyboardMsg, |_m|
            m := _m as KeyboardMsg

            path := "data/maps/edited_track.r2m"
            ("Saving track to " + path) println()

            fW := FileWriter new(path)
            fW write("R2MVersion 2\n\n")
            fW write("models {\n")
            fW write("  trackbound cube/cube.md5mesh\n")
            fW write("}\n\n")

            fW write("trackbounds {\n")
            lines each(|line|
                fW write(" ( %f %f ) ( %f %f )\n" format(
                    line get("begin", Float3) x,
                    line get("begin", Float3) y,
                    line get("end", Float3) x,
                    line get("end", Float3) y
                ))
            )
            fW write("}\n")
        )
    }
    
    onAdd: func {
        engine scene addModel(line)
    }

}


