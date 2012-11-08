
#include <CapacitiveSensor.h>
#include "LPD8806.h"
#include "SPI.h"

#define mode_lantern 0
#define mode_fire 1
#define mode_water 2
#define mode_earth 3
#define mode_air 4
#define number_of_modes 5

int modePins[number_of_modes] = {5, 6, 7, 8, 9};
int mode = 0;

// rotary potentiometers pin assignments and names:
int softPot1 = A0;
int softPot2 = A1;

// touch sensors pin assignments and names:
CapacitiveSensor   cs_2_3 = CapacitiveSensor(2,3);        // 1M resistor between pins 2 & 3, pin 3 is sensor pin, add a wire and or foil if desired
CapacitiveSensor   cs_2_4 = CapacitiveSensor(2,4);        // 1M resistor between pins 2 & 4, pin 4 is sensor pin, add a wire and or foil if desired

// turning on and off the lights
int sensor1reading = 0;
int oldsensor1reading = 0;
int onstate = 0; // 0 = off, 1 = on & animated, 2 = static

int sensor2reading = 0;
int oldsensor2reading = 0;
int colorstate = 0; // 0 = default for each mode, 1 = white

boolean lights_on = false;
boolean static_state = false;

// LED strip setup following:
int nLEDs = 32; // number of LEDs on strand
int dataPin  = 13; // Chose 2 pins for output; can be any valid output pins:
int clockPin = 12;
LPD8806 strip = LPD8806(32, dataPin, clockPin); 
/* First parameter is the number of LEDs in the strand.  The LED strips are 32 LEDs per meter but you can extend or cut the strip.  Next two parameters are SPI data and clock pins. */

void setup()
{

  for (int x=0; x < number_of_modes; x++) {
    pinMode(modePins[x], INPUT); 
  }

  Serial.begin(9600);
  strip.begin();
  strip.show();
}


void check_modes() {

  for (int x=0; x < number_of_modes; x++) {
    if (digitalRead(modePins[x]) == HIGH && mode != x) {
      mode = x;
      Serial.print("New Mode! ");
      Serial.println(mode, DEC);
      break; 
    }
  }
}

void loop() {

  // read reed switches and store their values as ____val

  check_modes();

  // capacitive sensors setup:
  long start = millis();                           // Capacitive Sensor setup
  long sensor1 =  cs_2_3.capacitiveSensor(30);      // Sensor 1 (on/static/off toggle)
  long sensor2 =  cs_2_4.capacitiveSensor(30);      // Sensor 2 (white/color toggle)

  Serial.print("\t");                    // tab character for debug window spacing
  Serial.print(sensor1);                  // print sensor output 1
  Serial.print("\t");
  Serial.println(sensor2);                  // print sensor output 2

  Serial.print("Mode: ");
  Serial.println(mode, DEC);

  delay(500);
  // if no modes are enabled, turn lights off & reset onstate to 0
  //  if ((lanternmode == false) && (firemode == false) && (watermode == false) && (earthmode == false) && (airmode == false)) {
  //    lights_on = false;
  //    onstate = 0;
  //    uint32_t c = strip.Color(0, 0, 0);    //turn LEDs off
  //    int i;
  //    for(i=0; i<strip.numPixels(); i++) {
  //      strip.setPixelColor(i, c);
  //      strip.show();
  //    }
  ////  Serial.println("all modes are OFF - lights off!"); 
  //  return;
  //  }

  // code for cycling from off to on to static to off:

  if (sensor1 >= 10) { // read sensor 1 & save the reading
    sensor1reading = HIGH;
  } 
  else {
    sensor1reading = LOW;
  }

  if (sensor1reading != oldsensor1reading && sensor1reading == HIGH) { // check if there was a transition since last time sensor1reading was saved
    onstate = onstate +1; // onstate can be = 1, 2, or 0 (off)
    if (onstate > 2) onstate = 0;
    Serial.print("onstate =");
    Serial.println(onstate);
  }

  oldsensor1reading = sensor1reading; // sensor1reading is now old, so store it to check later


  if (sensor2 >= 10) { // read sensor 2 and save the reading
    sensor2reading = HIGH;
  } 
  else {
    sensor2reading = LOW;
  }

  if (sensor2reading != oldsensor2reading && sensor2reading == HIGH) { // check if there was a transition since last time sensor1reading was saved3
    colorstate = 1 - colorstate; // colorstate can be = 1, or 0 (off), this inverts it
    Serial.print("colorstate =");
    Serial.println(colorstate);
  }

  oldsensor2reading = sensor2reading; // sensor1reading is now old, so store it to check later  


  // now for the lights:

  // the lantern is always static so jump to onstate 2
  //  if (lanternmode == true) {
  //    onstate = 2;
  //  }


  //turn on the lights if onstate = 1
  if (onstate == 1) {
    lights_on = true;
    Serial.println("onstate is 1");
  } 
  else if (onstate == 2) {
    static_state = true; // *** need to add this in below ***
    lights_on = false; //temporary while working on modes?
    Serial.println("onstate is 2");
  } 
  else if (onstate == 0) {
    lights_on = false;
    Serial.println("onstate is 0");
  }

  // ***need to add in color state stuff ***


  //  if (lanternmode == true && static_state == true) { // if both are activated...
  //    colorWipe(strip.Color(127,127,127), 0); // turn on all LEDs white with no delay
  // 
  //   } else if (firemode == true && lights_on == true) {
  //     fire();
  //      
  //   } else if (watermode == true && lights_on == true) {
  //     colorWipe(strip.Color(0,0,127), 0); // turn on all LEDs with no delay
  //      
  //   }  else if (earthmode == true && lights_on == true) {
  //     colorWipe(strip.Color(127,127,0), 0); // turn on all LEDs with no delay
  //     rainbow();
  //      
  //   }  else if (airmode == true && lights_on == true) {
  //     rainbow();     // rainbow cycle through colors 
  // 
  //   } else {   
  //     uint32_t c = strip.Color(0, 0, 0);    //turn LEDs off
  //     int i;
  //     for(i=0; i<strip.numPixels(); i++) {
  //       strip.setPixelColor(i, c);
  //       strip.show();
  //       onstate = 0;
  //       }
  //    }

} //end main loop


// color functions to follow: 


// Fill the dots progressively along the strip.
void colorWipe(uint32_t c, uint8_t wait) {
  int i;
  for (i=0; i < strip.numPixels(); i++) {
    strip.setPixelColor(i, c);
    strip.show();
    delay(wait);
  }
}

void rainbow() {
  int i; // variable number for pixels
  int j = 0; // variable reading of potentiometer
  j = analogRead(softPot1); // read pot
  Serial.print("j =");
  Serial.println(j);
  for (i=0; i < strip.numPixels(); i++) {
    if (j != 0) {
      strip.setPixelColor(i, (Wheel((j * 384L) /1024)));
    }
  }  
  strip.show();   // write all the pixels out
}

uint32_t Wheel(uint16_t WheelPos) {
  byte r, g, b;
  switch(WheelPos / 128) {
  case 0:
    r = 127 - WheelPos % 128;   //Red down
    g = WheelPos % 128;      // Green up
    b = 0;                  //blue off
    break; 
  case 1:
    g = 127 - WheelPos % 128;  //green down
    b = WheelPos % 128;      //blue up
    r = 0;                  //red off
    break; 
  case 2:
    b = 127 - WheelPos % 128;  //blue down 
    r = WheelPos % 128;      //red up
    g = 0;                  //green off
    break; 
  }
  return(strip.Color(r,g,b));
}

void runner() { // function that scrolls a single light down the strip
  int i; // variable number for pixels
  for (int x=0; x < strip.numPixels(); x++) {
    for (i=0; i < strip.numPixels(); i++) {
      strip.setPixelColor(i,strip.Color(0, 0, 0));
    }  
    strip.setPixelColor(x,strip.Color(127, 30, 0));
    strip.show();   // write all the pixels out
    delay(100);
  }  
}


void fire() { // fire animation function

  int i; // variable number for pixels
  int pixelvalue[strip.numPixels()]; // makes an array, so this makes each led act individually
  while (true) {
    for (i=0; i < strip.numPixels(); i++) { // for each frame, along the whole strip...
      pixelvalue[i] = changefire(pixelvalue[i]);  // change the pixel color according to changefire function
      strip.setPixelColor(i,firepixel(pixelvalue[i])); // tells the pixels to turn on with firepixel colors
      // will need to add an interrupt to check for sensor inputs
    }  
    strip.show();   // write all the pixels out
    delay(5);
  }  
}

uint32_t firepixel(uint16_t pixelvalue) { // maps the color values for fire
  return strip.Color(map(pixelvalue, 0, 384, 0, 127), map(pixelvalue, 0, 384, 0, 50), 0); // this map limits the range that red and green are allowed to flicker in (and sets blue to 0) red can go up to 127 and green can go
  up to 50.
}

uint16_t changefire(uint16_t oldpixel) { // randomizer function that tells the range for pixels to flicker
  int changeamount = random(-30, 30); // range for random fluctuation
  return constrain(oldpixel + changeamount, 0, 384); // makes sure that the random fluctuation doesn't exceed 384 or go below 0
}

