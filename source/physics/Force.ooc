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
