use glew
import glew

import Widget
import gfx/[Texture, RenderWindow], gfx/gl/GLPrimitives
import gameplay/Kart
import engine/Types

import math

SpeedoMeter: class extends Widget {

    kart: Kart
    texture := Texture new("data/images/speedometer_kmh.png")

    side := 80
    alphaMin := -220.0
    alphaMax :=  50.0
    
	init: func (=kart) {
		super("SpeedoMeter")
	}

    wRender: func {
        texture enable()
        glColor3f(1, 1, 1)
        glXYQuad(-side, side, side, -side)
        texture disable()

        glColor3f(1, 0, 0)
        
        alpha := (alphaMin + (alphaMax - alphaMin) * kart speed) / 180.0 * PI
        glLine(0, cos(alpha) * side * 0.8, 0, sin(alpha) * side * 0.8)
    }

    onAdd: func {
        super()
        
        win := engine getEntity("render_window") as RenderWindow
        get("position", Float3) set(win width * 4/5, win height * 4/5, 0)
        
        side = win width * 1/10
    }

}
