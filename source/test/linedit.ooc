import engine/[Engine, Entity, Property, Update, EventMapper, Message, Types]
import gfx/[RenderWindow, Cube, Scene, Grid, Line, Camera]
import gfx/md5/MD5Loader
import gfx/r2m/R2MLoader

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
    
    //--------------- Start the engine!
	engine run()
    
}
