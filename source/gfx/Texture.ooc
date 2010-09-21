use glew, sdl

import glew, sdl/[Core, Image]

/**
 * Represents an OpenGL texture
 */
Texture: class {

    fileName: String
    textureID: GLuint = -1

    init: func (fileName: String) {
        this fileName = fileName
        textureID = loadGLImage(fileName toCString())
    }

    enable: func {
        glEnable(GL_TEXTURE_2D)
        glBindTexture(GL_TEXTURE_2D, textureID)

        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE)
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
        
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    }

    disable: func {
        glDisable(GL_TEXTURE_2D)
    }
    
    loadGLImage: static func (fileName: Char*) -> GLuint {

        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE)
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
        
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)

        /*
		glPixelStorei(GL_UNPACK_ALIGNMENT, 1)
		glPixelStorei(GL_UNPACK_SKIP_ROWS, 0)
		glPixelStorei(GL_UNPACK_SKIP_PIXELS, 0)
		glPixelStorei(GL_UNPACK_ROW_LENGTH, 0)
		glPixelStorei(GL_UNPACK_SWAP_BYTES, GL_FALSE)
		glPixelStorei(GL_PACK_ALIGNMENT, 1)
        */
		
		"Loading texture %s..." printfln(fileName)
		
	    surface := IMG_Load(fileName)
	    
		texture: GLuint
		glGenTextures(1, texture&)
		glBindTexture(GL_TEXTURE_2D, texture)
		
		if(!surface) {
			"Texture not found: %s" printfln(fileName)
			return texture // empty texture, too bad :)
		}
		
		format := surface@ format@
		"Size: %dx%d, alpha = %d, bpp = %d, rMask = %x, gMask = %x, bMask = %x" printfln(
			surface@ w, surface@ h, format Amask, format BitsPerPixel, format Rmask, format Gmask, format Bmask)
		
		hasAlpha := (format Amask != 0)
		alphaFormat := (hasAlpha ? GL_RGBA : GL_RGB)
		
		desiredBpp := hasAlpha ? 32 : 24
		if(format BitsPerPixel != desiredBpp) {
			"Converting to %d bpp and RGB[A]!" printfln(desiredBpp)
			format BitsPerPixel = desiredBpp
			format Rmask = 0x000000ff
			format Gmask = 0x0000ff00
			format Bmask = 0x00ff0000
			format Amask = hasAlpha ? 0xff000000 : 0
			
			converted := SDL convertSurface(surface, format&, SDL_SWSURFACE)
			if(converted) {
				SDL freeSurface(surface)
				surface = converted
				"Converted surface has address %p" printfln(surface)
			}
		}
		
		// flip the texture.
		flippedSurface := flipSurface(surface)
		if(flippedSurface) {
			"Done flipping!" println()
			SDL freeSurface(surface)
			surface = flippedSurface
		}
		
		stdout flush()

        glGetError()
		glTexImage2D(
			GL_TEXTURE_2D,
			0,
			alphaFormat,
			surface@ w,
			surface@ h,
			0,
			alphaFormat,
			GL_UNSIGNED_BYTE,
			surface@ pixels
		)
        error := glGetError()
        "error is %d" printfln(error)
        SDL freeSurface(surface)

        "Finished loading, ID is %d" printfln(texture)
        
		texture
	}

}

// code that follows is gleefully stolen from http://www.lazyfoo.net/SDL_tutorials/lesson31/index.php

flipSurface: func (surface: Surface*) -> Surface* {
	format := surface@ format@
	
	(width, height) := (surface@ w, surface@ h)
	
    //Pointer to the soon to be flipped surface
    flipped := SDL createRgbSurface(
		SDL_SWSURFACE,
		width,
		height,
		format BitsPerPixel,
		format Rmask,
		format Gmask,
		format Bmask,
		format Amask
	)

	bpp := format BytesPerPixel

	// Flip pixels
	match (bpp) {
		case 3 =>
			srcPixels := surface@ pixels as UInt8*
			dstPixels := flipped@ pixels as UInt8*
			pitch := surface@ pitch
			
			for(y in 0..height) {
				for(x in 0..width) {
					ry := height - 1 - y
					
					dstPos := (height - 1 - y) * pitch + x * bpp
					srcPos := 			    y  * pitch + x * bpp
                    
					dstPixels[dstPos]     = srcPixels[srcPos]
					dstPixels[dstPos + 1] = srcPixels[srcPos + 1]
					dstPixels[dstPos + 2] = srcPixels[srcPos + 2]
					// you might think of the above as copying 'red, green, blue' separately.
					// well you'd be wrong. It might be BGR, too. And then there's endianing.
				}
			}
		case 4 =>
			srcPixels := surface@ pixels as UInt32*
			dstPixels := flipped@ pixels as UInt32*
		
			for(y in 0..height) {
				for(x in 0..width) {
					dstPixels[(height - 1 - y) * width + x] = srcPixels[y * width + x]
				}
			}
		case =>
			"Unsupported BPP: %d, not flipping surface." printfln(format BitsPerPixel)
			return null
	}

    flipped
}
