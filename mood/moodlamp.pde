#include <ShiftBar.h>

#define clockpin 13 // CI
#define enablepin 10 // EI
#define latchpin 9 // LI
#define datapin 11 // DI
 
#define randomSeedpin 0; // Analog

#define NumLEDs 5
#define RedLed 0
#define BlueLed 1
#define GreenLed 2

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

//LED brightness normilasation table. 
int gammatable[]={0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,2,2,2,2,2,3,3,3,4,4,4,5,5,6,6,6,7,7,8,8,9,10,10,11,12,12,13,14,14,15,16,17,18,19,19,20,21,22,23,24,26,27,28,29,30,31,33,34,35,36,38,39,41,42,44,45,47,48,50,52,53,55,57,58,60,62,64,66,68,70,72,74,76,78,80,82,85,87,89,92,94,96,99,101,104,106,109,112,114,117,120,123,125,128,131,134,137,140,143,146,149,153,156,159,162,166,169,172,176,179,183,187,190,194,198,201,205,209,213,217,221,225,229,233,237,241,246,250,254,258,263,267,272,276,281,286,290,295,300,305,310,314,319,324,329,335,340,345,350,355,361,366,372,377,383,388,394,400,405,411,417,423,429,435,441,447,453,459,465,472,478,484,491,497,504,510,517,524,530,537,544,551,558,565,572,579,586,593,601,608,615,623,630,638,645,653,661,668,676,684,692,700,708,716,724,732,740,749,757,765,774,782,791,800,808,817,826,835,844,853,862,871,880,889,898,908,917,926,936,945,955,965,974,984,994,1004,1014,1023};
int gammatableSize=256;
int gammatableMaxValue=1023;
int gammatableMinValue=0;

int GetNormalisedBrightness(int denormalisedBrightness)
{
  //TODO Check length of table
  return gammatable[denormalisedBrightness];  
}

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
  
  shiftBar.SetAllLedsColour(0,0,0);
  
  for (int i = 0; i<gammatableSize; i++) {
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
  for (int i = gammatableSize; i>0; i--)
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
  //fades from one colout to another.
  //red to yellow
  for (int i = 0; i<gammatableSize; i++)
  {
    int c=GetNormalisedBrightness(i);
    shiftBar.SetAllLedsColour(gammatableMaxValue,gammatableMinValue,c);
    shiftBar.WriteBufferToLEDArray();
    delay(colourStepInterval);
  }
  delay(colourChangeInterval);
  
  //yellow to green
  for (int i = gammatableSize-1; i>0; i--)
  {
    int c=GetNormalisedBrightness(i);
    shiftBar.SetAllLedsColour(c,gammatableMinValue,gammatableMaxValue);
    shiftBar.WriteBufferToLEDArray();
    delay(colourStepInterval);
  }
  delay(colourChangeInterval);
  
  //green to light blue
  for (int i = 0; i<gammatableSize; i++)
  {
    int c=GetNormalisedBrightness(i);
    shiftBar.SetAllLedsColour(gammatableMinValue,c,gammatableMaxValue);  
    shiftBar.WriteBufferToLEDArray();
    delay(colourStepInterval);
  }
  delay(colourChangeInterval);

  //light blue to blue
  for (int i = gammatableSize; i>0; i--)
  {
    int c=GetNormalisedBrightness(i);
    shiftBar.SetAllLedsColour(gammatableMinValue,gammatableMaxValue,c);  
    shiftBar.WriteBufferToLEDArray();
    delay(colourStepInterval);
  }
  delay(colourChangeInterval);
  
  //blue to purple
  for (int i = 0; i<gammatableSize; i++)
  {
    int c=GetNormalisedBrightness(i);
    shiftBar.SetAllLedsColour(c,gammatableMaxValue,gammatableMinValue);  
    shiftBar.WriteBufferToLEDArray();
    delay(colourStepInterval);
  }
  delay(colourChangeInterval);
  
  //Purple to red
  for (int i = gammatableSize-1; i>0; i--)
  {
    int c=GetNormalisedBrightness(i);
    shiftBar.SetAllLedsColour(gammatableMaxValue,c,gammatableMinValue);  
    shiftBar.WriteBufferToLEDArray();
    delay(colourStepInterval);
  }
  delay(colourChangeInterval);
  
}

void setup() {
  //off to white
  for (int i = 0; i<gammatableSize; i++)
  {
    int c=GetNormalisedBrightness(i);
    shiftBar.SetAllLedsColour(c,c,c);
    shiftBar.WriteBufferToLEDArray();
    delay(colourStepInterval);
  }
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
