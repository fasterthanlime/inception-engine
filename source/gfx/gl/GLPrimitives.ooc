use glew

import glew

glXYQuad: func (xmin, xmax, ymin, ymax: Float) {

    glBegin(GL_QUADS)
        glTexCoord2f(0, 0)
        glVertex2f(xmin, ymin)
        glTexCoord2f(0, 1)
        glVertex2f(xmin, ymax)
        glTexCoord2f(1, 1)
        glVertex2f(xmax, ymax)
        glTexCoord2f(1, 0)
        glVertex2f(xmax, ymin)
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


