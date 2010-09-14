use glew, devil
import glew, devil

/**
 * Represents an OpenGL texture
 */
Texture: class {

    textureID: GLuint = -1

    init: func (fileName: String) {
        ("Loading texture " + fileName + "...") println()
        textureID = ilutGLLoadImage(fileName toCString())
    }

    enable: func {
        glEnable(GL_TEXTURE_2D)
        glBindTexture(GL_TEXTURE_2D, textureID)
    }

    disable: func {
        glDisable(GL_TEXTURE_2D)
    }

}

