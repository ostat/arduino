#include <ShiftBar.h>

#define clockpin 13 // CI
#define enablepin 10 // EI
#define latchpin 9 // LI
#define datapin 11 // DI
 
#define randomSeedpin 0; // Analog

#define NumLEDs 5
#define RedLed 0
#define GreenLed 1
#define BlueLed 2

int LedBuffer[NumLEDs][3] = {0};
int LedCurrent[NumLEDs][3] = {0};
int LedTarget[NumLEDs][3] = {0};

int LedStepTarget[NumLEDs][3] = {0};
int LedStepTime = 25;

int colourStepInterval = 100;
int colourChangeInterval = 1000;

long previousMillis = 0;            // variable to store last time LED was updated
long startTime ;                    // start time for stop watch
long elapsedTime ;                  // elapsed time for stop watch

ShiftBar shiftBar(clockpin, enablepin, latchpin, datapin, NumLEDs);

unsigned long seedOut(unsigned int noOfBits)
{
  // return value with 'noOfBits' random bits set
  unsigned long seed=0;
  while (noOfBits--)
    seed = (seed<<1) | (analogRead(0)&1);
  return seed;  
}

void SleepColours() {
//produces fade effect

    int ledSleep[NumLEDs][3] = {0};
    for (int led = 0;led<NumLEDs;led++) {
        ledSleep[led][RedLed] = LedBuffer[led][RedLed];
        ledSleep[led][BlueLed] = LedBuffer[led][BlueLed];
        ledSleep[led][GreenLed] = LedBuffer[led][GreenLed];
    }
  
  shiftBar.BufferAllLedsColour(0,0,0);
  
  for (int i = 0; i<ShiftBar::MaxColourValue; i++) {
     for (int led = 0;led<NumLEDs;led++) {
       LedBuffer[led][RedLed] = i <= ledSleep[led][RedLed] ? i : ledSleep[led][RedLed];
       LedBuffer[led][BlueLed] = i <= ledSleep[led][BlueLed] ? i : ledSleep[led][BlueLed];
       LedBuffer[led][GreenLed] = i <= ledSleep[led][GreenLed] ? i : ledSleep[led][GreenLed];
     }
     shiftBar.WriteBufferToLEDArray();
     delay(colourStepInterval);
  }
  
  delay(colourChangeInterval);
  
  //yellow to green
  for (int i = ShiftBar::MaxColourValue; i>0; i--)
  {
    for (int led = 0;led<NumLEDs;led++) {
       LedBuffer[led][RedLed] = i > ledSleep[led][RedLed] ? ledSleep[led][RedLed] : i ;
       LedBuffer[led][BlueLed] = i > ledSleep[led][BlueLed] ? ledSleep[led][BlueLed] : i ;
       LedBuffer[led][GreenLed] = i > ledSleep[led][GreenLed] ? ledSleep[led][GreenLed] : i ;
     }
     shiftBar.WriteBufferToLEDArray();
     delay(colourStepInterval);
  }
  delay(colourChangeInterval);
}

void Rainbow() {
  //fades from one colour to another.
  //red (1,0,0) to yellow (1,1,0)
  for (int i = 0; i<ShiftBar::MaxNormalisedColourValue; i++)
  {
    shiftBar.BufferAllLedsColourNormalised(ShiftBar::MaxNormalisedColourValue,i,0);
    shiftBar.WriteBufferToLEDArray();
    delay(colourStepInterval);
  }
  delay(colourChangeInterval);
  
  //yellow (1,1,0) to green (0,1,0)
  for (int i = ShiftBar::MaxNormalisedColourValue; i>0; i--)
  {
    shiftBar.BufferAllLedsColourNormalised(i,ShiftBar::MaxNormalisedColourValue,0);
    shiftBar.WriteBufferToLEDArray();
    delay(colourStepInterval);
  }
  delay(colourChangeInterval);
  
  //green (0,1,0) to aqua (0,1,1)
  for (int i = 0; i<ShiftBar::MaxNormalisedColourValue; i++)
  {
    shiftBar.BufferAllLedsColourNormalised(0,ShiftBar::MaxNormalisedColourValue,i);  
    shiftBar.WriteBufferToLEDArray();
    delay(colourStepInterval);
  }
  delay(colourChangeInterval);

  //aqua (0,1,1) to blue (0,0,1)
  for (int i = ShiftBar::MaxNormalisedColourValue; i>0; i--)
  {
    shiftBar.BufferAllLedsColourNormalised(0,i,ShiftBar::MaxNormalisedColourValue);  
    shiftBar.WriteBufferToLEDArray();
    delay(colourStepInterval);
  }
  delay(colourChangeInterval);
  
  //blue (0,0,1) to purple (1,0,1)
  for (int i = 0; i<ShiftBar::MaxNormalisedColourValue; i++)
  {
    shiftBar.BufferAllLedsColourNormalised(i,0,ShiftBar::MaxNormalisedColourValue);  
    shiftBar.WriteBufferToLEDArray();
    delay(colourStepInterval);
  }
  delay(colourChangeInterval);
  
  //Purple (1,0,1) to red (1,0,0)
  for (int i = ShiftBar::MaxNormalisedColourValue; i>0; i--)
  {
    shiftBar.BufferAllLedsColourNormalised(ShiftBar::MaxNormalisedColourValue,0,i);  
    shiftBar.WriteBufferToLEDArray();
    delay(colourStepInterval);
  }
  delay(colourChangeInterval);
}


void setup() {
  shiftBar.BufferLedCommand(0,100,120,120);
  shiftBar.BufferLedCommand(1,100,120,120);
  shiftBar.BufferLedCommand(2,100,120,120);
  shiftBar.BufferLedCommand(3,100,120,120);
  shiftBar.BufferLedCommand(4,120,120,100);
  
  shiftBar.BufferAllLedsColour(0,0,0);
  shiftBar.BufferLedColourNormalised(0,50,50,50);
  shiftBar.WriteBufferToLEDArray();
  delay(colourChangeInterval);
  shiftBar.BufferAllLedsColour(0,0,0);
  shiftBar.BufferLedColourNormalised(1,50,50,50);
  shiftBar.WriteBufferToLEDArray();
  delay(colourChangeInterval);
  shiftBar.BufferAllLedsColour(0,0,0);
  shiftBar.BufferLedColourNormalised(2,50,50,50);
  shiftBar.WriteBufferToLEDArray();
  delay(colourChangeInterval);
  shiftBar.BufferAllLedsColour(0,0,0);
  shiftBar.BufferLedColourNormalised(3,50,50,50);
  shiftBar.WriteBufferToLEDArray();
  delay(colourChangeInterval);
  shiftBar.BufferAllLedsColour(0,0,0);
  shiftBar.BufferLedColourNormalised(4,50,50,50);
  shiftBar.WriteBufferToLEDArray();
  delay(colourChangeInterval);
  
  shiftBar.WriteBufferToLEDArray();
  //off (0,0,0) to white (1,1,1)
  for (int i = 0; i<ShiftBar::MaxNormalisedColourValue; i++)
  {
    shiftBar.BufferAllLedsColourNormalised(i,i,i);
    shiftBar.WriteBufferToLEDArray();
    delay(colourStepInterval);
  }
  delay(colourChangeInterval);
  //White (1,1,1) to red (1,0,0)
  for (int i = ShiftBar::MaxNormalisedColourValue; i>0; i--)
  {
    shiftBar.BufferAllLedsColourNormalised(ShiftBar::MaxNormalisedColourValue,i,i);
    shiftBar.WriteBufferToLEDArray();
    delay(colourStepInterval);
  }
  delay(colourChangeInterval);
}

void loop()
{
  Rainbow();
}

//void loop_flicker()
//{
//   for (int led = 0;led<NumLEDs;led++) {
//     LedBuffer[led][RedLed] = seedOut(10);
//     LedBuffer[led][BlueLed] = seedOut(10);
//     LedBuffer[led][GreenLed] = seedOut(10);
//   }
//   int interval = 100; //making code compile, this should be declared else where
//   if ( (millis() - previousMillis > interval) ) {
//
//      if (blinking == true){
//         previousMillis = millis();                         // remember the last time we blinked the LED
//
//         // if the LED is off turn it on and vice-versa.
//         if (value == LOW)
//            value = HIGH;
//         else
//            value = LOW;
//         digitalWrite(ledPin, value);
//      }
//      else{
//         digitalWrite(ledPin, LOW);                         // turn off LED when not blinking
//      }
//   }
//   
//   SleepColours();
//   delay(colourChangeInterval);
//}
