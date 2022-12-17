#if !defined(SP_GRAPH_H_INCLUDED)
#define SP_GRAPH_H_INCLUDED

#include "sp_stand.cpp"

void setTextMode(void);
void setGraphicsMode(void);
void putPixel(int x, int y, Byte attribute);
void line(Word x1, Word y1, Word x2, Word y2, Byte attr);
void box(Word x1, Word y1, Word x2, Word y2, Byte attr);
void clearScreen(void);
void setCursor(Byte row, Byte column);

#define SCREEN_WIDTH 320
#define SCREEN_HEIGHT 200

#endif

