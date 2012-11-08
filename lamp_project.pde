#include <TimerOne.h>
#include <CapacitiveSensor.h>
#include "LPD8806.h"
#include "SPI.h"

//#define lanternMode_lantern 0
//#define lanternMode_fire 1
//#define lanternMode_water 2
//#define lanternMode_earth 3
//#define lanternMode_air 4

#define buttonMode_off 0
#define buttonMode_solid 1
#define buttonMode_pattern 2

#define number_of_lanternModes 5
#define sensorThreshold 2000

#define switch_debounce 100
#define button_debounce 100

long lastSwitchCheck;
long lastButtonCheck;


int lanternPins[number_of_lanternModes] = {5, 6, 7, 8, 9};
int lanternMode = 0;

int buttonMode = 0;

// rotary potentiometers pin assignments and names:
int softPot1 = A0;
int softPot2 = A1;

// touch sensors pin assignments and names:
CapacitiveSensor   cs_2_3 = CapacitiveSensor(2,3);        // 1M resistor between pins 2 & 3, pin 3 is sensor pin, add a wire and or foil if desired
CapacitiveSensor   cs_2_4 = CapacitiveSensor(2,4);        // 1M resistor between pins 2 & 4, pin 4 is sensor pin, add a wire and or foil if desired

// turning on and off the lights
int old_sensor1 = LOW;
//int oldsensor1reading = 0;

int old_sensor2 = LOW;

//int onstate = 0; // 0 = off, 1 = on & animated, 2 = static
//
//int sensor2reading = 0;
//int oldsensor2reading = 0;
//int colorstate = 0; // 0 = default for each lanternMode, 1 = white

//boolean lights_on = false;
//boolean static_state = false;

// LED strip setup following:
int nLEDs = 32; // number of LEDs on strand
int dataPin  = 12; // Chose 2 pins for output; can be any valid output pins:
int clockPin = 11;
LPD8806 strip = LPD8806(32, dataPin, clockPin); 
/* First parameter is the number of LEDs in the strand.  The LED strips are 32 LEDs per meter but you can extend or cut the strip.  Next two parameters are SPI data and clock pins. */

void setup()
{

  for (int x=0; x < number_of_lanternModes; x++) {
    pinMode(lanternPins[x], INPUT); 
  }

  Timer1.initialize(33333);
  Timer1.attachInterrupt(callback);

  Serial.begin(115200);
  strip.begin();
  strip.show();

}

void callback() {
  Serial.println("Callback");

  if (buttonMode == buttonMode_off) {
    uint32_t c = strip.Color(0, 0, 0);    //turn LEDs off
    for(int i=0; i<strip.numPixels(); i++) {
      strip.setPixelColor(i, c);
    }
    strip.show();

  } 

  else if (buttonMode == buttonMode_solid) {
    uint32_t c = strip.Color(127, 127, 127);    //turn LEDs off
    for(int i=0; i<strip.numPixels(); i++) {
      strip.setPixelColor(i, c);
    }
    strip.show();
  }
  
  else if (buttonMode == buttonMode_pattern) {
    
    
  }
}

void check_switches() {
  
  if (millis() - lastSwitchCheck < switch_debounce) return;
  else lastSwitchCheck = millis();
  
  for (int x=0; x < number_of_lanternModes; x++) {
    if (digitalRead(lanternPins[x]) == HIGH && lanternMode != x) {
      lanternMode = x;
      Serial.print("New lanternMode! ");
      Serial.println(lanternMode, DEC);
      break; 
    }
  }
}

void check_buttons() {
  
  if (millis() - lastButtonCheck < button_debounce) return;
  else lastButtonCheck = millis();
  
  long start = millis();                           // Capacitive Sensor setup
  long sensor1 =  cs_2_3.capacitiveSensor(30);      // Sensor 1 (on/static/off toggle)
  long sensor2 =  cs_2_4.capacitiveSensor(30);      // Sensor 2 (white/color toggle)

  if (sensor1 > sensorThreshold && old_sensor1 == LOW) {
    old_sensor1 = HIGH;
    buttonMode += 1;

    if (buttonMode == 3) buttonMode = 0;

    Serial.print("Sensor1 state changed: ");
    Serial.println(sensor1, DEC);

  } 
  else if (sensor1 == 0 && old_sensor1 == HIGH) {
    old_sensor1 = LOW; 
    Serial.println("Sensor1 went LOW");
    Serial.print("buttonMode: ");
    Serial.println(buttonMode, DEC);
  }
}

void loop() {

  // read reed switches and store their values as ____val

  check_switches();
  check_buttons();

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
  //up to 50.
}

uint16_t changefire(uint16_t oldpixel) { // randomizer function that tells the range for pixels to flicker
  int changeamount = random(-30, 30); // range for random fluctuation
  return constrain(oldpixel + changeamount, 0, 384); // makes sure that the random fluctuation doesn't exceed 384 or go below 0
}

void colorChase(uint32_t c, uint8_t wait) {
  int i;

  // Start by turning all pixels off:
  for(i=0; i<strip.numPixels(); i++) strip.setPixelColor(i, 0);

  // Then display one pixel at a time:
  for(i=0; i<strip.numPixels(); i++) {
    strip.setPixelColor(i, c); // Set new pixel 'on'
    strip.show();              // Refresh LED states
    strip.setPixelColor(i, 0); // Erase pixel, but don't refresh!
    delay(wait);
  }

  strip.show(); // Refresh to turn off last pixel
}


