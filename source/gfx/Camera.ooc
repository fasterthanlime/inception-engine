use glew, glu, sdl

import glew, glu/Glu, sdl/[Core, Event]
import engine/[Types, Entity, Property, Message]
import math

FIRST_PERSON := 1
THIRD_PERSON := 2

Camera: class extends Entity {
	phi, theta: Float
	forward := Float3 new(0, 0, 0)
	left := Float3 new(0, 0, 0)
	
	pos := Float3 new(5, 0, 0)
	target := Float3 new(0, 0, 0)
	
	kforward := false
	kbackward := false
	kstrafe_left := false
	kstrafe_right := false
	
	mode := FIRST_PERSON
	
	init: func ~cam (.name){
		super(name)
		set("position",  pos)
		set("target", target)
		set("speed", 1.0)
		set("sensitivity", 0.2)
		phi = 0
		theta = 0
		listen(MouseMotion, This onMouseMotion)
		listen(KeyboardMsg, This onKey)
		vectorsFromAngles()
	}
	
	init: func ~camfull(=pos, =target, .name) {
        diff := target - pos
        
        dist := sqrt(diff y * diff y + diff x * diff x)
		phi   = atan2(diff z, dist  ) / PI * 180.0
		theta = atan2(diff y, diff x) / PI * 180.0
		init(name)
	}
	
	onMouseMotion: static func(m: MouseMotion) {
		this := m target
        
        sensitivity := get("sensitivity", Float)
		theta -= m dx * sensitivity
		phi   -= m dy * sensitivity
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
		pos = get("position", Float3)
		target = get("target", Float3)
		speed := get("speed", Float)
        
		if(kforward) { pos = pos + forward * speed }
		if(kbackward) { pos = pos - forward * speed }
		if(kstrafe_left) { pos = pos + left * speed }
		if(kstrafe_right) { pos = pos - left * speed }
        
		target set(pos + forward)
        
		set("position", pos)
		set("target", target)

        //"Camera pos / target = %s / %s" printfln(pos toString() toCString(), target toString() toCString())
		
	    gluLookAt(pos x, pos y, pos z,
				  target x, target y, target z,
				  0, 0, 1)
	}
	
	vectorsFromAngles: func {
		pos = get("position", Float3)
		target = get("target", Float3)
		speed := get("speed", Float)
		
		up := Float3 new(0,0,1)
		if(phi > 89)
			phi = 89
		else if(phi < -89)
			phi = -89
        
        rTemp := cos(phi * PI / 180.0)
        forward z = sin(phi * PI / 180.0)
        forward x = rTemp * cos(theta * PI / 180.0)
        forward y = rTemp * sin(theta * PI / 180.0)
        
        left = up ^ forward
        left normalize()
    
        target set(pos + forward)
		
		set("target", target)
	}
}
