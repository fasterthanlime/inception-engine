use glew,glu,sdl
import glew,glu/Glu,sdl/[Sdl, Event]
import engine/[Types, Entity, Property, Message]

Camera: class extends Entity {
	phi, theta: Float
	forward := Float3 new(0,0,0)
	left := Float3 new(0,0,0)
	
	kforward := false
	kbackward := false
	kstrafe_left := false
	kstrafe_right := false
	
	init: func ~cam (.name){
		super(name)
		set("pos", Float3 new(5,5,5))
		set("target", Float3 new(0,0,0))
		set("speed",1.0)
		set("sensitivity",0.2)
		phi = 0
		theta = 0
		listen(MouseMotion,This onMouseMotion)
		listen(KeyboardMsg,This onKey)
		vectorsFromAngles()
	}
	
	onMouseMotion: static func(m: MouseMotion) {
		this := m target
		sensitivity := get("sensitivity",Float)
		theta -= m dx * sensitivity
		phi -= m dy * sensitivity
		vectorsFromAngles()
	}
	
	onKey: static func(m: KeyboardMsg) {
		this := m target
		if(m type == SDL_KEYDOWN) {
			match(m key) {
				case SDLK_w => kforward = true
				case SDLK_s => kbackward = true
				case SDLK_a => kstrafe_left = true
				case SDLK_d => kstrafe_right = true
			}
		} else if(m type == SDL_KEYUP) {
			match(m key) {
				case SDLK_w => kforward = false
				case SDLK_s => kbackward = false
				case SDLK_a => kstrafe_left = false
				case SDLK_d => kstrafe_right = false
			}
		}
	}
	
	look: func {
		pos := get("pos",Float3)
		target := get("target",Float3)
		speed := get("speed",Float)	
		
		if(kforward) { pos = pos + forward * speed }
		if(kbackward) { pos = pos - forward * speed }
		if(kstrafe_left) { pos = pos + left * speed }
		if(kstrafe_right) { pos = pos - left * speed }
		target = pos + forward
		
		set("pos",pos)
		set("target",target)
		
	    gluLookAt(pos x,pos y,pos z,
				  target x, target y, target z,
				  0,0,1)
	}
	
	vectorsFromAngles: func {
		pos := get("pos",Float3)
		target := get("target",Float3)
		speed := get("speed",Float)
		
		up := Float3 new(0,0,1)
		if(phi > 89)
			phi = 89
		else if(phi < -89)
			phi = -89
			
		rTemp := cos(phi*PI/180.0)
		forward z = sin(phi * PI / 180.0)
		forward x = rTemp * cos(theta * PI / 180.0)
		forward y = rTemp * sin(theta * PI / 180.0)
		
		left = up ^ forward
		left normalize()
		
		target = pos + forward
		
		set("target",target)
	}
}