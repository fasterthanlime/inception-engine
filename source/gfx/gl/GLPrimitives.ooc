use glew

import glew

glXYQuad: func (xmin, xmax, ymin, ymax: Float) {

    glBegin(GL_QUADS)
        glTexCoord2f(0, 0)
        glVertex3f(xmin, ymin, 0)
        glTexCoord2f(0, 1)
        glVertex3f(xmin, ymax, 0)
        glTexCoord2f(1, 1)
        glVertex3f(xmax, ymax, 0)
        glTexCoord2f(1, 0)
        glVertex3f(xmax, ymin, 0)
    glEnd()

}

glLine: func (xmin, xmax, ymin, ymax, zmin = 0, zmax = 0 : Float) {

    glLineWidth(6)
    glBegin(GL_LINES)
        glVertex3f(xmin, ymin, zmin)
        glVertex3f(xmax, ymax, zmax)
    glEnd()
    glLineWidth(1)
    
}


