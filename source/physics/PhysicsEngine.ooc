import structs/LinkedList
import Force,Body
import engine/[Entity, Types]
import gfx/Model

PhysicsEngine: class extends Entity {
	forces := LinkedList<Force> new()
	bodies := LinkedList<Body> new()
	tempForce := Float3 new(0,0,0)
	dt := 0.01
	
	init: func ~physx {
		super("physx")
		set("time_step",dt)
		forces add(Gravity new())
	}
	update: func {
		//here we apply all the forces to each physical object
		for(body in bodies) {
			for(force in forces) {
				force get(body,tempForce)
				body applyForce(tempForce)
			}
		}
		
		
		for(body in bodies) {
			body evolve(dt)
		}
	}
	
	bind: func(m: Model, b: Body) {
		bodies add(b)
		b pos bind(m pos)
		b rot bind(m rot)
	}
}
