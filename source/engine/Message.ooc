import structs/HashMap

Message: abstract class {
	type := static genId()

	genId: static func -> Int {
		idSeed := static 0
		value := idSeed
		idSeed += 1
		return value
	}
}
