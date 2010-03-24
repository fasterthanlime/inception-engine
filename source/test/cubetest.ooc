import engine/[Engine, Entity, Property, Update]
import gfx/[RenderWindow, Cube, Scene]


main: func {
	
	engine := Engine new()
	cube := Cube new("Cube 1")
	win := RenderWindow new(800,600,32,false,"Cube")
	scene := Scene new("my scene with a beautiful cube =)")
	scene models add(cube)
	win scene = scene
	engine run()
}
