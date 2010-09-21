import engine/[Types,Entity]
import Force, Geometry
import structs/LinkedList

DAMP := 0.9990

Body: class extends Entity {
    
	pos := Float3 new() //in m
	vel := Float3 new() //in m/s
	acc := Float3 new() //in m/s/s
	rot := Float3 new() //in degrees
	mass := 1.0  // in kg
	fixed := false //does the body react to forces?
	
	forces := LinkedList<Force> new()
    geom : Geometry = null
	
	tmpForce := Float3 new()
	
	init: func ~body(.name) {
		super(name)
		set("position",     pos)
		set("velocity",     vel)
		set("acceleration", acc)
		set("rotation",     rot)
        set("geometry",     geom)
	}
	
	init: func ~full(=pos,=vel,.name) {
		init(name)
	}
    
    setGeometry: func (=geom) {
        geom set("position", pos)
    }
	
	evolve: func(dt: Float) { // in seconds	
		if(fixed)
			return

        //"Evolving body, dt = %.4f, vel = %s" printfln(dt, vel toString() toCString())
        
        // Using a fixed timestep solves jittering problems - FPS is stabilized elsewhere anyway
        dt = 0.02;
            
		for(force in forces) {
            force compute(this, tmpForce)
			acc x += tmpForce x / mass
			acc y += tmpForce y / mass
			acc z += tmpForce z / mass
		}
		
		vel x += acc x * dt
		vel y += acc y * dt
		vel z += acc z * dt
		
		vel x *= DAMP
		vel y *= DAMP
		vel z *= DAMP
		
		pos addSet(
            vel x * dt,
			vel y * dt,		
            vel z * dt		
        )
		
		acc set(0, 0, 0)
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
		pos
	}
	
	setVel: func(x,y,z: Float) {
		vel set(x,y,z)
	}
	
    setFixed: func(=fixed) {}
    
	addForce: func(f: Force) {
		forces add(f)
	}
	
	setMass: func(=mass) {
		if(mass == 0)
			mass = 0.01
	}
    
}
