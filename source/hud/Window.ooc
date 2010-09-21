use sdl, glew, glu

import sdl/[Core, Event]
import glew, glu/Glu
import gfx/Model
import engine/[Types, Message, Entity]
import math

import Widget

Window: class extends Widget {

    alpha := 128
	focus := true

	selected := false
	hovered := false
	
	border:= 10  //in pixels
	
	//hover bools
	bottom := false
	top := false
	left := false
	right := false
	
	ulcorner := false
	urcorner := false
	dlcorner := false
	drcorner := false
	
	//select bools
	bottoms := false
	tops := false
	lefts := false
	rights := false
	
	ulcorners := false
	urcorners := false
	dlcorners := false
	drcorners := false
	
	
	init: func ~windowinit (.name,x, y, width, height: Float) {
		super(name)
        set("position", Float3 new(x, y, 0))
		set("size",     Float2 new(width, height))
		listen(MouseButton, This mouseHandle)
		listen(MouseMotion, This mouseMotion)        
	}

    render: func {
        if(!show) return
            
		pos := get("position", Float3)
		glTranslated(pos x, pos y, 0)
        background()
		round(border)
		wRender()
    }
	
	mouseHandle: static func(m: MouseButton) {
		this := m target
		if(m type == SDL_MOUSEBUTTONDOWN) {
			if(hovered) {
				selected = true
			} 
			if(bottom) {
				bottoms = true
			} 
			if(top) {
				tops = true
			} 
			if(left) {
				lefts = true
			} 
			if(right) {
				rights = true
			} 
			if(ulcorner) {
				ulcorners = true
			} 
			if(urcorner) {
				urcorners = true
			} 
			if(dlcorner) {
				dlcorners = true
			} 
			if(drcorner) {
				drcorners = true
			} 
		}
		
		if(m type == SDL_MOUSEBUTTONUP) {
			selected = false
			bottoms = false
			tops = false
			lefts = false
			rights = false
			ulcorners = false
			urcorners = false
			dlcorners = false
			drcorners = false
		}
	}
	
	mouseMotion: static func(m: MouseMotion) {
		this := m target
		pos := get("position", Float3)
		size := get("size", Float2)
		
		left = false
		right = false
		top = false
		bottom = false
		hovered = false
		ulcorner = false
		urcorner = false
		dlcorner = false
		drcorner = false
		
		//testing for center bounds, for console moving
		if(m x >= pos x && m x <= (pos x + size x) && 
		   m y >= pos y && m y <= (pos y + size y)) {
			   hovered = true
		   } 
	
		//now left border
		if(m x >= pos x - border && m x < pos x && 
		   m y > pos y && m y < pos y + size y) {
			   left = true
		   }
		   
		//now right border
		if(m x > pos x + size x && m x <= pos x + size x + border && 
		   m y > pos y && m y < pos y + size y) {
			   right = true
		   }
		   
		//now top border
		if(m x >= pos x && m x <= pos x + size x &&
		   m y >= pos y - border && m y < pos y) {
			   top = true
		   }
		   
		//now bottom border
		if(m x >= pos x && m x <= pos x + size x &&
		   m y > pos y + size y && m y <= pos y + size y + border) {
			   bottom = true
		   }
		   
		//now upper left corner
		if(m x < pos x && m x >= pos x - border &&
		   m y < pos y && m y >= pos y - border) {
			   ulcorner = true
		   }
		   
		//now upper right corner
		if(m x > pos x  + size x && m x <= pos x + size x + border &&
		   m y < pos y && m y >= pos y - border) {
			   urcorner = true
		   }
		   
		//now lower right corner
		if(m x > pos x  + size x && m x <= pos x + size x + border &&
		   m y > pos y + size y && m y <= pos y + size y + border) {
			   drcorner = true
		   }
		   
		// now lower left corner
		if(m x < pos x && m x >= pos x - border &&
		   m y > pos y + size y && m y <= pos y + size y + border) {
			   dlcorner = true
		   }
		   
		if(selected)
			pos set(pos x + m dx, pos y + m dy,0)
			
		if(lefts) {
			size set(size x - m dx, size y)
			pos set(pos x + m dx, pos y,0)
		}
		
		if(rights) {
			size set(size x + m dx, size y)
			pos set(pos x, pos y,0)
		}
		
		if(tops) {
			size set(size x , size y - m dy)
			pos set(pos x, pos y + m dy,0)
		}
		
		if(bottoms) {
			size set(size x , size y + m dy)
			pos set(pos x, pos y,0)
		}
		
		if(ulcorners) {
			size set(size x - m dx , size y - m dy)
			pos set(pos x + m dx, pos y + m dy,0)
		}
		
		if(urcorners) {
			size set(size x + m dx , size y - m dy)
			pos set(pos x, pos y + m dy,0)
		}
		
		if(drcorners) {
			size set(size x + m dx , size y + m dy)
			pos set(pos x, pos y,0)
		}
		
		if(dlcorners) {
			size set(size x - m dx , size y + m dy)
			pos set(pos x + m dx, pos y,0)
		}
		
		if(size x < border * 2) {
			bottoms = false
			tops = false
			lefts = false
			rights = false
			ulcorners = false
			urcorners = false
			dlcorners = false
			drcorners = false
			size x = border * 2
		}
			
		if(size y < border * 2) {
			bottoms = false
			tops = false
			lefts = false
			rights = false
			ulcorners = false
			urcorners = false
			dlcorners = false
			drcorners = false
			size y = border * 2
		}
	}
	
	
	background: func {
		size := get("size",Float2)
		alpha2 := alpha
		if(hovered && !bottoms && !tops && !lefts && !rights && !ulcorners && !urcorners && !dlcorners && !drcorners && focus)
			alpha2 = alpha + 30
		
		glBegin(GL_QUADS)
			glColor4ub(255, 255, 255,alpha2)
			glVertex2i(0, 0)
			glVertex2i(size x, 0)
			glVertex2i(size x,size y)
			glVertex2i(0, size y)
		glEnd()         
	}
	
	round: func(rsize: Float) {
		size := get("size",Float2)
		alpha2 := alpha
		if(((bottom || top || left || right || ulcorner || urcorner || dlcorner || drcorner && !selected) ||
			(bottoms || tops || lefts || rights || ulcorners || urcorners || dlcorners || drcorners)) && focus)
			alpha2 += 30
		glColor4ub(255,255,255,alpha2)
		glPushMatrix()
		//drawing the upper left corner
		angle1 := PI
		angle2 := 3.0*PI/2.0
		step := PI/2.0/10.0
		glBegin(GL_TRIANGLE_FAN)
		glVertex2f(0,0)
		while(angle1 <= angle2) {
			glVertex2f(cos(angle1)*rsize,sin(angle1)*rsize)
			angle1 += step
		}
		glVertex2f(cos(angle2)*rsize,sin(angle2)*rsize)
		glEnd()
		
		//upper right
		glTranslated(size x,0,0)
		angle1 = 3.0*PI/2.0
		angle2 = 4.0*PI/2.0
		glBegin(GL_TRIANGLE_FAN)
		glVertex2f(0,0)
		while(angle1 <= angle2) {
			glVertex2f(cos(angle1)*rsize,sin(angle1)*rsize)
			angle1 += step
		}
		glVertex2f(cos(angle2)*rsize,sin(angle2)*rsize)
		glEnd()
		
		//lower right
		glTranslated(0,size y,0)
		angle1 = 0.0
		angle2 = PI/2.0
		glBegin(GL_TRIANGLE_FAN)
		glVertex2f(0,0)
		while(angle1 <= angle2) {
			glVertex2f(cos(angle1)*rsize,sin(angle1)*rsize)
			angle1 += step
		}
		glVertex2f(cos(angle2)*rsize,sin(angle2)*rsize)
		glEnd()
		
		//lower left
		glTranslated(-size x,0,0)
		angle1 = PI/2.0
		angle2 = PI
		step = angle1/10.0
		glBegin(GL_TRIANGLE_FAN)
		glVertex2f(0,0)
		while(angle1 <= angle2) {
			glVertex2f(cos(angle1)*rsize,sin(angle1)*rsize)
			angle1 += step
		}
		glVertex2f(cos(angle2)*rsize,sin(angle2)*rsize)
		glEnd()
		
		glPopMatrix()
		
		glPushMatrix()
		glBegin(GL_QUADS)
			glVertex2f(0,0)
			glVertex2f(0 - rsize,0)
			glVertex2f(0 - rsize,0 + size y)
			glVertex2f(0,0 + size y)
		glEnd()
		
		glBegin(GL_QUADS)
			glVertex2f(0,0 - rsize)
			glVertex2f(0 + size x,0 - rsize)
			glVertex2f(0 + size x,0)
			glVertex2f(0,0)
		glEnd()
		
		glBegin(GL_QUADS)
			glVertex2f(0 + size x,0)
			glVertex2f(0 + size x + rsize,0)
			glVertex2f(0 + size x + rsize,0 + size y)
			glVertex2f(0 + size x,0 + size y)
		glEnd()
		
		glBegin(GL_QUADS)
			glVertex2f(0,0 + size y)
			glVertex2f(0,0 + size y + rsize)
			glVertex2f(0 + size x,0 + size y + rsize)
			glVertex2f(0 + size x,0 + size y)
		glEnd()
		glPopMatrix()
	}
}
