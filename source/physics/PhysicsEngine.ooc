import structs/LinkedList
import Force, Body, Geometry
import engine/[Engine,Entity, Types]
import gfx/Model
import console/Console

PhysicsEngine: class extends Entity {
	forces := LinkedList<Force> new()
	bodies := LinkedList<Body> new()
	tempForce := Float3 new(0,0,0)
	
	init: func ~physx {
		super("physx")
		set("speed", 1.0)
	}
    
	update: func {
        speed := get("speed", Float)
        
		dt := engine dt as Float / 1000.0
        
		//here we apply all the forces to each physical object
		for(body in bodies) {
			for(force in forces) {
				force compute(body, tempForce)
				body applyForce(tempForce)
			}
		}
        
        // here we do collision detection between all
        for(body1 in bodies) {
            for(body2 in bodies) {
                if(body1 == body2) continue // of course.
                
                if(body1 geom collide(body2 geom, tempForce)) {
                    //engine getEntity("console", Console) cprint("%s <> %s ! (%.2f, %.2f, %.2f)\n" format(body1 name, body2 name, tempForce x, tempForce y, tempForce z))
                    body1 pos += tempForce
                }
            }
        }
		
        // each body apply their own forces to themselves, and update
        // their velocity and position accordingly
		for(body in bodies) {
			body evolve(speed*dt)
		}
        
        
	}
	
    add: func (b: Body) {
		bodies add(b)
        engine addEntity(b)
    }
    
    add: func ~withModel (b: Body, m: Model) {
        add(b)
        engine addEntity(m)
		b pos bind(m pos)
		b rot bind(m rot)
	}
	
	addForce: func (f: Force) {
		forces add(f)
	}
}
