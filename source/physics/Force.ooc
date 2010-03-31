import engine/Types
import physics/Body

Force: class {
	none := static Float3 new(0,0,0)
	init: func {
	}
	
	get: func(b: Body, force: Float3) {
		force set(0,0,0)
	}
}

Gravity: class extends Force {
	acc := 0.0
	init: func ~gravity (=acc) {
	}
	
	init: func ~gravempty {
		init(-9.81)
	}
	
	get: func(b: Body, force: Float3) {
		force set(0,0,acc * b mass)
	}
}

SpringForce: class extends Force {
	kconst := 2.0
	targetLength := 1.0
	targetSpot := Float3 new(0,0,0)
	init: func ~spring(=kconst,=targetLength,=targetSpot) {
		
	}
	
	init: func ~withbody(=kconst, =targetLength,body1,body2: Body ) {
		targetSpot = body2 getPos()
		body2 addForce(This new(kconst,targetLength,body1 getPos()))
	}
	
	get: func(b: Body, force: Float3) {
		d := dist(b pos, targetSpot)
		force set(kconst*(targetSpot x - b pos x)/d*(d - targetLength),
				  kconst*(targetSpot y - b pos y)/d*(d - targetLength),
				  kconst*(targetSpot z - b pos z)/d*(d - targetLength)
				)
	}	
}
