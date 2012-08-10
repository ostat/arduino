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
int SB_CommandMode;
int SB_RedCommand;
int SB_GreenCommand;
int SB_BlueCommand;

int colourChangeDelay = 10;
int colourStableDelay = 1000;

void setup() {
 
   pinMode(datapin, OUTPUT);
   pinMode(latchpin, OUTPUT);
   pinMode(enablepin, OUTPUT);
   pinMode(clockpin, OUTPUT);
   
   SPCR = (1<<SPE)|(1<<MSTR)|(0<<SPR1)|(0<<SPR0);
   
   digitalWrite(latchpin, LOW);
   digitalWrite(enablepin, LOW);
 
   //white to yellow
  for (int i = 0; i<1024; i++)
  {
   SetAllLedsColour(i,i,i);
   WriteLEDArray();
   delay(colourChangeDelay);
  }
}

unsigned long seedOut(unsigned int noOfBits)
{
  // return value with 'noOfBits' random bits set
  unsigned long seed=0;
  while (noOfBits--)
    seed = (seed<<1) | (analogRead(0)&1);
  return seed;  
}

void SetAllLedsColour(int red, int blue, int green) {
  //Sets the array for all LED's to be this colour 
   for (int led = 0;led<NumLEDs;led++) {
   LedBuffer[led][RedLed] = red;
   LedBuffer[led][BlueLed] = blue;
   LedBuffer[led][GreenLed] = green;
   }
}

void SetLedColour(int led, int red, int blue, int green) { 
  //Sets the ledBuffer for 'led' to the specific colour
   LedBuffer[led][RedLed] = red;
   LedBuffer[led][BlueLed] = blue;
   LedBuffer[led][GreenLed] = green;
}

void SB_SendPacket() {
    //Sends data packet to LED's
    if (SB_CommandMode == B01) {
     SB_RedCommand = 120;
     SB_GreenCommand = 100;
     SB_BlueCommand = 100;
    }
 
    SPDR = SB_CommandMode << 6 | SB_BlueCommand>>4;
    while(!(SPSR & (1<<SPIF)));
    SPDR = SB_BlueCommand<<4 | SB_RedCommand>>6;
    while(!(SPSR & (1<<SPIF)));
    SPDR = SB_RedCommand << 2 | SB_GreenCommand>>8;
    while(!(SPSR & (1<<SPIF)));
    SPDR = SB_GreenCommand;
    while(!(SPSR & (1<<SPIF)));
}
 
void WriteLEDArray() {
    SB_CommandMode = B00; // Write to PWM control registers
    for (int h = 0;h<NumLEDs;h++) {
	  SB_RedCommand = LedBuffer[h][0];
          LedCurrent[h][0] = LedBuffer[h][0];
	  SB_GreenCommand = LedBuffer[h][1];
	  LedCurrent[h][1] = LedBuffer[h][1];
	  SB_BlueCommand = LedBuffer[h][2];
	  LedCurrent[h][2] = LedBuffer[h][2];
	  SB_SendPacket();
    }
 
    delayMicroseconds(15);
    digitalWrite(latchpin,HIGH); // latch data into registers
    delayMicroseconds(15);
    digitalWrite(latchpin,LOW);
 
    SB_CommandMode = B01; // Write to current control registers
    for (int z = 0; z < NumLEDs; z++) SB_SendPacket();
    delayMicroseconds(15);
    digitalWrite(latchpin,HIGH); // latch data into registers
    delayMicroseconds(15);
    digitalWrite(latchpin,LOW); 
}

void loop()
{
   for (int led = 0;led<NumLEDs;led++) {
   LedBuffer[led][RedLed] = seedOut(10);
   LedBuffer[led][BlueLed] = seedOut(10);
   LedBuffer[led][GreenLed] = seedOut(10);
   }
   
   SleepColours();
   delay(colourChangeDelay);
}

void SleepColours() {
  //produces fade effect
  int ledSleep[NumLEDs][3] = {0};
  for (int led = 0;led<NumLEDs;led++) {
   ledSleep[led][RedLed] = LedBuffer[led][RedLed];
   ledSleep[led][BlueLed] = LedBuffer[led][BlueLed];
   ledSleep[led][GreenLed] = LedBuffer[led][GreenLed];
  }
  
  SetAllLedsColour(0,0,0);
  
  for (int i = 0; i<1024; i++) {
     for (int led = 0;led<NumLEDs;led++) {
       LedBuffer[led][RedLed] = i <= ledSleep[led][RedLed] ? i : ledSleep[led][RedLed];
       LedBuffer[led][BlueLed] = i <= ledSleep[led][BlueLed] ? i : ledSleep[led][BlueLed];
       LedBuffer[led][GreenLed] = i <= ledSleep[led][GreenLed] ? i : ledSleep[led][GreenLed];
     }
     WriteLEDArray();
     delay(colourChangeDelay);
  }
  
  delay(colourStableDelay);
  
  //yellow to green
  for (int i = 1023; i>0; i--)
  {
    for (int led = 0;led<NumLEDs;led++) {
       LedBuffer[led][RedLed] = i > ledSleep[led][RedLed] ? ledSleep[led][RedLed] : i ;
       LedBuffer[led][BlueLed] = i > ledSleep[led][BlueLed] ? ledSleep[led][BlueLed] : i ;
       LedBuffer[led][GreenLed] = i > ledSleep[led][GreenLed] ? ledSleep[led][GreenLed] : i ;
     }
     WriteLEDArray();
     delay(colourChangeDelay);
  }
  
  delay(colourStableDelay);
}

void Rainbow() {
  //fades from one colout to another.
  //red to yellow
  for (int i = 0; i<1024; i++)
  {
   SetAllLedsColour(1023,0,i);
   WriteLEDArray();
   delay(colourChangeDelay);
  }
  delay(colourStableDelay);
  
  //yellow to green
  for (int i = 1023; i>0; i--)
  {
   SetAllLedsColour(i,0,1023);
   WriteLEDArray();
   delay(colourChangeDelay);
  }
  delay(colourStableDelay);
  
  //green to light blue
  for (int i = 0; i<1024; i++)
  {
   SetAllLedsColour(0,i,1023);  
   WriteLEDArray();
   delay(colourChangeDelay);
  }
  delay(colourStableDelay);

  //light blue to blue
  for (int i = 1023; i>0; i--)
  {
   SetAllLedsColour(0,1023,i);  
   WriteLEDArray();
   delay(colourChangeDelay);
  }
  delay(colourStableDelay);
  
  //blue to purple
  for (int i = 0; i<1024; i++)
  {
   SetAllLedsColour(i,1023,0);  
   WriteLEDArray();
   delay(colourChangeDelay);
  }
  delay(colourStableDelay);
  
  //Purple to red
  for (int i = 1023; i>0; i--)
  {
   SetAllLedsColour(1023,i,0);  
   WriteLEDArray();
   delay(colourChangeDelay);
  }
  delay(colourStableDelay);
}
