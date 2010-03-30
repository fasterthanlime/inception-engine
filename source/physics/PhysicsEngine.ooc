import structs/LinkedList
import Force,Body
import engine/[Engine,Entity, Types]
import gfx/Model

PhysicsEngine: class extends Entity {
	forces := LinkedList<Force> new()
	bodies := LinkedList<Body> new()
	tempForce := Float3 new(0,0,0)
	speed := 1.0
	
	
	init: func ~physx {
		super("physx")
		set("physx_speed",speed)
		forces add(Gravity new())
	}
	update: func {
		dt := engine dt as Float / 1000.0
		//here we apply all the forces to each physical object
		for(body in bodies) {
			for(force in forces) {
				force get(body,tempForce)
				body applyForce(tempForce)
			}
		}
		
		for(body in bodies) {
			body evolve(speed*dt)
		}
	}
	
	bind: func(m: Model, b: Body) {
		bodies add(b)
		b pos sset(m pos)
		b pos bind(m pos)
		b rot bind(m rot)
	}
}
