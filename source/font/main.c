#include <stdlib.h> 
#include <time.h>
#include <GL/glut.h>
#include <FTGL/ftgl.h>

static FTGLfont *font;

FTGLfont *getFont() {
	return font;
}

void initFont(int x, int y) {
	font = ftglCreateTextureFont("font/Terminus.ttf");
	ftglSetFontFaceSize(font, x, y);
    ftglSetFontCharMap(font, ft_encoding_unicode);
    printf("initing font =)\n");
}

void renderFont(double x, double y,double s, int mirror, const char* text) {
	glPushMatrix();
	glTranslated(x,y,0);
	glScaled(s,s,s);
	if(mirror){
		glRotated(180.0,1,0,0);
	}
	ftglRenderFont(font, text, FTGL_RENDER_ALL);
	glPopMatrix();
}
