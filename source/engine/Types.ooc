import Update

Float3: class {
	updates: Update[]
	x,y,z: Float
	init: func(=x,=y,=z) {}
	
	set: func(=x,=y,=z){
		for(update in updates) {
			update run()
		}
	}
}
