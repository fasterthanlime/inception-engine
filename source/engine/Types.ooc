import Update,Entity,Message
import structs/ArrayList

Float3: class {
	clients: Entity[]
	x,y,z: Float
	
	init: func(=x,=y,=z) {}
	
	set: func(=x,=y,=z){
		for(client in clients) {
			client send(client,ValueChange get(this))
		}
	}
}

Float2: class {
	clients: Entity[]
	x,y: Float
	init: func(=x,=y) {}
	
	set: func(=x,=y){
		for(client in clients) {
			client send(client,ValueChange get(this))
		}
	}
}
