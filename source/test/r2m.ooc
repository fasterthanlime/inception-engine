import engine/[Engine, Entity, Property, Update, EventMapper, Message, GLConsole, Types]
import gfx/[RenderWindow, Cube, Scene, Grid, Line]
import gfx/md5/MD5Loader
import gfx/r2m/R2MLoader
import physics/[PhysicsEngine, Body, Force]

main: func (argc: Int, argv: String*) {
	
	engine := Engine new()
	
	win := RenderWindow new(1200, 800, 32, false, "render_window")
	win listen(QuitMessage, RenderWindow quit)
	//win listen(QuitMessage, |m| win quit())
	
	//---------------------
	physx := PhysicsEngine new()
	physx addForce(Gravity new())
	
	cube1 := Cube new("cube_1") .setPos(-5,0,0)
	cube2 := Cube new("cube_2") .setPos(5,0,0)
	cube3 := Cube new("cube_3") .setPos(0,0,0)
	cube4 := Cube new("cube_4") .setPos(4,0,0)
	
	
	
	cubebody4 := Body new("cube_4_body") .setMass(0.1)
	cubebody3 := Body new("cube_3_body") .setMass(10) .addForce(SpringForce new(10,1,cubebody3,cubebody4))
	cubebody2 := Body new("cube_2_body") .addForce(SpringForce new(80,1,cubebody2,cubebody3))
	cubebody1 := Body new("cube_1_body") .addForce(SpringForce new(80,1,cubebody1,cubebody3))
	cubebody1 fixed = true
	cubebody2 fixed = true
	
	line1 := Line new("spring_line_34",cubebody4,cubebody3)
	line2 := Line new("spring_line_13",cubebody1,cubebody3)
	line3 := Line new("spring_line_23",cubebody2,cubebody3)
	
	engine addEntity(cube1)
	engine addEntity(cube2)
	engine addEntity(cube3)
	engine addEntity(cube4)
	
	engine addEntity(line1)
	engine addEntity(line2)
	engine addEntity(line3)
	
	physx bind(cube1,cubebody1)
	physx bind(cube2,cubebody2)
	physx bind(cube3,cubebody3)
	physx bind(cube4,cubebody4)
	
	/*prevCube := Cube new("cube_0") .setPos(0,0,0)
	engine addEntity(prevCube)
	prevBody := Body new("cube_0_body")
	physx bind(prevCube,prevBody)
	for(i in 1..20) {
		cube := Cube new("cube_%d" format(i)) .setPos(2.0*i,0,0)
		cubebody := Body new("cube_%d_body" format(i)) .addForce(SpringForce new(10.0,1.0,prevBody,cubebody))
		engine addEntity(cube)
		physx bind(cube,cubebody)
		prevCube = cube
		prevBody = cubebody
	}*/
		//-------------------
	
	//engine addSpawnable("m_cube",Cube new)
	//engine spawn("m_cube","cube_2",Float3 new(0,0,0))
	
    path := argc >= 2 ? argv[1] : "data/maps/square.r2m"
   // engine addEntity(R2MLoader new() load(path))
	engine addEntity(Grid new("grid_1"))
    
	engine addEntity(EventMapper new())
	engine addEntity(win)
	engine addEntity(physx)
    
	engine run()
}
