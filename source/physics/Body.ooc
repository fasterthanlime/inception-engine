import engine/[Types,Entity]

Body: class extends Entity {
	pos := Float3 new(0,0,0) //in m
	vel := Float3 new(0,0,0) //in m/s
	acc := Float3 new(0,0,0) //in m/s/s
	rot := Float3 new(0,0,0) //in degrees
	mass := 1.0   //in kg
	
	init: func ~body {
		set("position",pos)
		set("velocity",vel)
		set("acceleration",acc)
		set("rotation",rot)	
	} 
	

}
