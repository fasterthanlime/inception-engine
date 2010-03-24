import engine/[Engine, Entity, Property, Update]
import gfx/[RenderWindow, Cube, Scene]


main: func {
	
	engine := Engine new()
	
	win := RenderWindow new(800, 600, 32, false, "Cube")
	scene := Scene new("my scene with a beautiful cube =)")
	
	cube := Cube new("Cube 1")
	scene models add(cube)
	
	engine addEntity(scene)
	engine addEntity(win)
	engine run()
}
