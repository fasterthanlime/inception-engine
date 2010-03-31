import engine/[Types,Entity]
import physics/Force
import structs/LinkedList

DAMP := 0.90

Body: class extends Entity {
	pos := Float3 new(0,0,0) //in m
	vel := Float3 new(0,0,0) //in m/s
	acc := Float3 new(0,0,0) //in m/s/s
	rot := Float3 new(0,0,0) //in degrees
	mass := 1.0   //in kg
	fixed := false //does the body react to forces?
	
	forces := LinkedList<Force> new()
	
	tmp_force := Float3 new(0,0,0)
	
	init: func ~body(.name) {
		super(name)
		set("position",pos)
		set("velocity",vel)
		set("acceleration",acc)
		set("rotation",rot)	
	}
	
	init: func ~full(=pos,=vel,.name) {
		init(name)
	}
	
	evolve: func(dt: Float) { //in seconds
		if(fixed)
			return
			
		for(force in forces) {
			force get(this,tmp_force)
			acc x += tmp_force x / mass
			acc y += tmp_force y / mass
			acc z += tmp_force z / mass
		}
		
		vel x += acc x * dt
		vel y += acc y * dt
		vel z += acc z * dt
		
		vel x *= DAMP
		vel y *= DAMP
		vel z *= DAMP
		
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
	
	setPos: func(x,y,z: Float) {
		pos set(x,y,z)
	}
	
	getPos: func -> Float3 {
		return pos
	}
	
	setVel: func(x,y,z: Float) {
		vel set(x,y,z)
	}
	
	addForce: func(f: Force) {
		forces add(f)
	}
	
	setMass: func(=mass) {
		if(mass == 0)
			mass = 0.01
	}
}
