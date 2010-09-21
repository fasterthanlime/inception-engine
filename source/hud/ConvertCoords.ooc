use glew, glu, sdl

import glew, glu/Glu, sdl/[Core, Event]
import engine/[Types, Entity, Property, Message]
import math

ConvertCoords: class extends Entity {

    coords := Float3 new(0, 0, 0)

    init: func {
        super("3d_coords")
        set("coords", coords)
        
        listen(MouseMotion, |_m|
            m := _m as MouseMotion
        
            //glLoadIdentity()
            viewport: GLint[4]
            modelview: GLdouble[16]
            projection: GLdouble[16]
            winX, winY, winZ: GLfloat
            posX, posY, posZ: GLdouble

            glGetDoublev(GL_MODELVIEW_MATRIX, modelview as GLdouble*)
            glGetDoublev(GL_PROJECTION_MATRIX, projection as GLdouble*)
            glGetIntegerv(GL_VIEWPORT, viewport as GLint*)

            winX = m x
            winY = viewport[3] - (m y as Float)
            glReadPixels(m x, winY as Int, 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, winZ&)
            
            gluUnProject(winX, winY, winZ, modelview, projection, viewport, posX&, posY&, posZ&)
            posZ += 0.0001

            coords set(posX, posY, posZ)
            set("coords", coords)
            "Got world coords (%.2f, %.2f, %.2f) / mouse coords (%.2f, %.2f, %.2f)" printfln(posX, posY, posZ, winX, winY, winZ)
        )
    }

}
