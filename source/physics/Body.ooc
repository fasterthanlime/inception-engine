import engine/[Types,Entity]

Body: class extends Entity {
	pos := Float3 new(0,0,0) //in m
	vel := Float3 new(0,0,0) //in m/s
	acc := Float3 new(0,0,0) //in m/s/s
	rot := Float3 new(0,0,0) //in degrees
	mass := 1.0   //in kg
	
	init: func ~body(.name) {
		super(name)
		set("position",pos)
		set("velocity",vel)
		set("acceleration",acc)
		set("rotation",rot)	
	} 
	
	evolve: func(dt: Float) { //in seconds
		vel x += acc x * dt
		vel y += acc y * dt
		vel z += acc z * dt
		
		pos addSet( vel x * dt,
					vel y * dt,		
					vel z * dt		
			)
		
		acc set(0,0,0)
	}
	
	applyForce: func(force: Float3) {
		acc x += force x / mass
		acc y += force y / mass
		acc z += force z / mass
	}
}
