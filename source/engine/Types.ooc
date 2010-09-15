import Update,Entity,Message
import structs/[ArrayList,LinkedList]
import math

extend Float {
    min: func(others: ...) -> This {
        minimum := this
        others each(|other|
            val := other as Float
            if(val < minimum) minimum = val
        )
        minimum
    }
    
    max: func(others: ...) -> This {
        maximum := this
        others each(|other|
            val := other as Float
            if(val > maximum) maximum = val
        )
        maximum
    }
}

Float3: class {
	clients := ArrayList<Entity> new()
	bindings := LinkedList<This> new()
	x, y, z: Float
	
	init: func ~xyz (=x, =y, =z) {}
    
    init: func ~zero {
        x = y = z = 0
    }
	
	set: func (=x, =y, =z) {
		for(client in clients) {
			client send(client, ValueChange get(this))
		}
		
		for(bindf in bindings) {
			bindf sset(this)
		}
	}

    set: func ~f3 (other: This) {
        set(other x, other y, other z)
    }

    clone: func -> This {
        new(x, y, z)
    }
	
	addSet: func(x, y, z: Float) {
		this x += x
		this y += y
		this z += z
		
		for(client in clients) {
			client send(client, ValueChange get(this))
		}
		
		for(bindf in bindings) {
			bindf sset(this)
		}
	}
	
	bind: func(f: Float3) {
		bindings add(f)
	}
	
	sset: func(f: Float3) { // silent set, doesn't dispatch it to everyone that wanted it, muahhaha
		x = f x
		y = f y
		z = f z
	}
	
	normalize: func {
        scale(1 / length())
	}
    
    negate: func {
        x = -x
        y = -y
        z = -z
    }

    scale: func (factor: Float) {
        x *= factor
        y *= factor
        z *= factor
    }
	
    dot: func (b: Float3) -> Float {
        x * b x + y * b y + z * b z
    }
    
    squaredLength: func -> Float {
        dot(this)
    }
    
	length: func -> Float {
		sqrt(squaredLength())
	}
	
	toString: func -> String {
		"(%.2f, %.2f, %.2f)" format(x,y,z)
	}
}

dist: func ~f2 (f1, f2: Float2) -> Float {
	sqrt(
        (f1 x - f2 x) * (f1 x - f2 x) +
        (f1 y - f2 y) * (f1 y - f2 y)
    )
}

dist: func ~f3 (f1, f2: Float3) -> Float {
	sqrt(
        (f1 x - f2 x) * (f1 x - f2 x) +
        (f1 y - f2 y) * (f1 y - f2 y) +
        (f1 z - f2 z) * (f1 z - f2 z)
    )
}

operator * (v1: Float3, n: Float) -> Float3 {
	Float3 new(v1 x * n, v1 y * n, v1 z * n)
}

operator / (v1: Float3, n: Float) -> Float3 {
	return Float3 new(v1 x / n, v1 y / n, v1 z / n)
}

operator + (v1,v2: Float3) -> Float3 {
	Float3 new(v1 x + v2 x, v1 y + v2 y, v1 z + v2 z)
}

operator += (v1,v2: Float3) {
	v1 set(v1 x + v2 x, v1 y + v2 y, v1 z + v2 z)
}

operator - (v1,v2: Float3) -> Float3 {
	Float3 new(v1 x - v2 x, v1 y - v2 y, v1 z - v2 z)
}

operator ^ (v1,v2: Float3) -> Float3 {
	Float3 new (
		v1 y * v2 z - v1 z * v2 y,
		v1 z * v2 x - v1 x * v2 z,
		v1 x * v2 y - v2 y * v2 x
	)
}

Float2: class {
	clients := ArrayList<Entity> new()
	x, y: Float
	init: func(=x, =y) {}
	
	set: func(=x, =y){
		for(client in clients) {
			client send(client, ValueChange get(this))
		}
	}

    scale: func (factor: Float) {
        x *= factor
        y *= factor
    }

    normalize: func {
        scale(1 / length())
	}
    
    dot: func (b: Float2) -> Float {
        x * b x + y * b y
    }
    
    squaredLength: func -> Float {
        dot(this)
    }
    
	length: func -> Float {
		sqrt(squaredLength())
	}
}

Int2: class {
	clients := ArrayList<Entity> new()
	x, y: Int
	init: func(=x, =y) {}
	
	set: func(=x, =y) {
		for(client in clients) {
			client send(client, ValueChange get(this))
		}
	}
}
