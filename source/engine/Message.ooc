import structs/HashMap
import Entity

Message: abstract class {

    sender, target: Entity

	genId: static func -> Int {
		idSeed := static 0
		value := idSeed
		idSeed += 1
		return value
	}
    
    clone: func -> This {
        // MWAHAHAHAHAHAHAHAHAHAHAH
        copy := gc_malloc(class instanceSize)
        memcpy(copy, this, class instanceSize)
        return copy
    }
    
}

MouseMotion: class extends Message {
	x,y,dx,dy: Int
	init: func ~mm (=x,=y,=dx,=dy){}
}

KeyboardMsg: class extends Message {
	key: Int
	type : Int //keyup or keydown
	init: func ~km (=key, =type) {}
}


ValueChange: class <T> extends Message {
	value: T
	
	init: func ~vc (=value) {}
	
	get: static func <T> (t: T) -> This<T> {
		This<T> new(t)
	}
}

ResizeEvent: class extends Message {
	x,y: Int
	init: func ~winev(=x,=y) {}
}

Command: class extends Message {
}

QuitMessage: class extends Message {
	
}

