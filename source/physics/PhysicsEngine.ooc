import structs/LinkedList
import Force,Body
import engine/Entity

PhysicsEngine: class extends Entity {
	forces := LinkedList<Force> new()
	bodies := LinkedList<Body> new()
	
	init: func ~physx {
		forces add(Gravity new())
	}
	update: func {
		//here we apply all the forces to each physical object
	}
}
