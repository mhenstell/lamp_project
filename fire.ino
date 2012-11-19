#include <stdint.h>

// fire effect
int fire[width][height];

// Flame colors
long palette[255];
float angle;
int calc1[width], calc3[width], calc4[width];
int calc2[height], calc5[height];


long HSV_to_RGB( float h, float s, float v ) {
  /*
     modified from Alvy Ray Smith's site:
   http://www.alvyray.com/Papers/hsv2rgb.htm
   H is given on [0, 6]. S and V are given on [0, 1].
   RGB is returned as a 24-bit long #rrggbb
   */
  int i;
  float m, n, f;

  // not very elegant way of dealing with out of range: return black
  if ((s<0.0) || (s>1.0) || (v<0.0) || (v>1.0)) {
    return 0L;
  }

  if ((h < 0.0) || (h > 6.0)) {
    return long( v * 255 ) + long( v * 255 ) * 256 + long( v * 255 ) * 65536;
  }
  i = floor(h);
  f = h - i;
  if ( !(i&1) ) {
    f = 1 - f; // if i is even
  }
  m = v * (1 - s);
  n = v * (1 - s * f);
  switch (i) {
  case 6:
  case 0: // RETURN_RGB(v, n, m)
    return long(v * 255 ) * 65536 + long( n * 255 ) * 256 + long( m * 255);
  case 1: // RETURN_RGB(n, v, m) 
    return long(n * 255 ) * 65536 + long( v * 255 ) * 256 + long( m * 255);
  case 2:  // RETURN_RGB(m, v, n)
    return long(m * 255 ) * 65536 + long( v * 255 ) * 256 + long( n * 255);
  case 3:  // RETURN_RGB(m, n, v)
    return long(m * 255 ) * 65536 + long( n * 255 ) * 256 + long( v * 255);
  case 4:  // RETURN_RGB(n, m, v)
    return long(n * 255 ) * 65536 + long( m * 255 ) * 256 + long( v * 255);
  case 5:  // RETURN_RGB(v, m, n)
    return long(v * 255 ) * 65536 + long( m * 255 ) * 256 + long( n * 255);
  }
} 

void fire_setup() {

  for (int x=0; x < 255; x++) {
    palette[x] = HSV_to_RGB((x/3) / 15, 1, (constrain(x*3, 0, 255) / 255));
  }

  for (int x = 0; x < width; x++) {
    calc1[x] = x % width;
    calc3[x] = (x - 1 + width) % width;
    calc4[x] = (x + 1) % width;
  }

  for (int y = 0; y < height; y++) {
    calc2[y] = (y + 1) % height;
    calc5[y] = (y + 2) % height;
  }

}

void draw() {
  angle = angle + 0.05;

  for (int x = 0; x < width; x++)
  {
    fire[x][height-1] = int(random(0, 190)) ;
  }

  int counter = 0;

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      // Add pixel values around current pixel

      fire[x][y] =
        ((fire[calc3[x]][calc2[y]]
        + fire[calc1[x]][calc2[y]]
        + fire[calc4[x]][calc2[y]]
        + fire[calc1[x]][calc5[y]]) << 5) / 129;

      // Output everything to screen using our palette colors
     // pixels[counter] = palette[fire[x][y]];
      strip.setPixelColor(height * x + y, palette[fire[x][y]]);

    
      // Extract the red value using right shift and bit mask 
      // equivalent of red(pg.pixels[x+y*w])
//      if ((pg.pixels[counter++] >> 16 & 0xFF) == 128) {
//        // Only map 3D cube 'lit' pixels onto fire array needed for next frame
//        fire[x][y] = 128;
//      }


    }
  }
}



