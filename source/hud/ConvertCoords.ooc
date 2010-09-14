use glew, glu, sdl

import glew, glu/Glu, sdl/[Sdl, Event]
import engine/[Types, Entity, Property, Message]
import math

ConvertCoords: class extends Entity {

    init: func {
        super("3d_coords")
        set("x", 0.0)
        set("y", 0.0)
        set("z", 0.0)

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
            //winZ = 0
            
            gluUnProject(winX, winY, winZ, modelview, projection, viewport, posX&, posY&, posZ&)

            set("x", posX as Float)
            set("y", posY as Float)
            set("z", posZ as Float)
            
            "Got world coords (%.2f, %.2f, %.2f) / mouse coords (%.2f, %.2f, %.2f)" printfln(posX, posY, posZ, winX, winY, winZ)
        )
    }

}
