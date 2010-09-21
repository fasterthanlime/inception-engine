import engine/[Engine, Entity, Property, Update, EventMapper, Message]
import gfx/[RenderWindow, Cube, Scene, Quad, Texture]
import gfx/md5/[MD5Loader, MD5Model]

main: func (argc: Int, argv: CString*) {
	
	engine := Engine new()
	
	win := RenderWindow new(1024, 768, 32, false, "md5 test")
    engine addEntity(EventMapper new())
    engine addEntity(win)

    path := argc >= 2 ? argv[1] toString() : "data/models/ogro/ogro.md5mesh"
    md5model := MD5Loader load(path)
	engine addEntity(md5model)

    quad := Quad new("quad")
    quad texture = Texture new("data/models/ogro/skin.png")
    engine addEntity(quad)
    
	engine run()
    
}
