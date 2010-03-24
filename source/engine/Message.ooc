import structs/HashMap
import Entity

Message: abstract class {

    sender: Entity

	genId: static func -> Int {
		idSeed := static 0
		value := idSeed
		idSeed += 1
		return value
	}
    
}

