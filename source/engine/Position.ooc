import Property,Types


Position: class extends Property {
	value : Float3
	
	init: func ~position (.name) {
		super(name)
	}
}
