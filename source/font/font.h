#ifndef M_FONT_H
#define M_FONT_H

#include <FTGL/ftgl.h>

void initFont(int x, int y);

void renderFont(double x, double y,double s, int mirror, const char* text);

FTGLfont *getFont();


#endif
