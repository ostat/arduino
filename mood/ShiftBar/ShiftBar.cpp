/*
  ShifBar.cpp - Library for comunicating with shifbars and compatible devices.
  Created by Chris Heazlewood, November 1, 2011.
  Released into the public domain.
*/

#include "ShiftBar.h"
#include "Arduino.h"

//Positions in array
#define RedLed 0
#define GreenLed 1
#define BlueLed 2

//in microseconds, used to when latching data to the LED Driver Chip 
#define LatchDelay 15

//LED brightness normilasation table. 
int gammaCorrectionTable[]={0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,2,2,2,2,2,3,3,3,4,4,4,5,5,6,6,6,7,7,8,8,9,10,10,11,12,12,13,14,14,15,16,17,18,19,19,20,21,22,23,24,26,27,28,29,30,31,33,34,35,36,38,39,41,42,44,45,47,48,50,52,53,55,57,58,60,62,64,66,68,70,72,74,76,78,80,82,85,87,89,92,94,96,99,101,104,106,109,112,114,117,120,123,125,128,131,134,137,140,143,146,149,153,156,159,162,166,169,172,176,179,183,187,190,194,198,201,205,209,213,217,221,225,229,233,237,241,246,250,254,258,263,267,272,276,281,286,290,295,300,305,310,314,319,324,329,335,340,345,350,355,361,366,372,377,383,388,394,400,405,411,417,423,429,435,441,447,453,459,465,472,478,484,491,497,504,510,517,524,530,537,544,551,558,565,572,579,586,593,601,608,615,623,630,638,645,653,661,668,676,684,692,700,708,716,724,732,740,749,757,765,774,782,791,800,808,817,826,835,844,853,862,871,880,889,898,908,917,926,936,945,955,965,974,984,994,1004,1014,1023};
int ShiftBar::MaxColourValue=1023;
int ShiftBar::MaxNormalisedColourValue=255;
int ShiftBar::MaxCommandValue=127;

// LED buffer values, that will be written next
int _ledColourBuffer[5][3];
int _ledCommandBuffer[5][3];
// Previously written values, current state
int _ledColourCurrent[5][3];

ShiftBar::ShiftBar(int clockpin, int enablepin, int latchpin, int datapin, int numberLeds)
{
	_clockpin = clockpin;
	_enablepin = enablepin;
	_latchpin = latchpin;
	_datapin = datapin;
	SetNumberLeds(numberLeds);

	pinMode(datapin, OUTPUT);
	pinMode(latchpin, OUTPUT);
	pinMode(enablepin, OUTPUT);
	pinMode(clockpin, OUTPUT);

	SPCR = (1<<SPE)|(1<<MSTR)|(0<<SPR1)|(0<<SPR0);

	digitalWrite(latchpin, LOW);
	digitalWrite(enablepin, LOW);
}

void ShiftBar::SetNumberLeds(int numberLeds)
{
  //TODO: this should create the arrays. 
	_numberLeds = numberLeds;
  for (int led = 0; led < _numberLeds; led++) {
    BufferLedCommand(led, MaxCommandValue, MaxCommandValue, MaxCommandValue);
	}
}

void ShiftBar::BufferAllLedsColour(int red, int green, int blue) {
  //buffers the same assigned colour to all LED's
	for (int led = 0; led < _numberLeds; led++) {
    BufferLedColour(led, red, green, blue);
	}
}

void ShiftBar::BufferAllLedsColourNormalised(int red, int green, int blue) {
  //buffers the same assigned colour to all LED's
	for (int led = 0; led < _numberLeds; led++) {
    BufferLedColourNormalised(led, red, green, blue);
	}
}
  
void ShiftBar::BufferLedColour(int led, int red, int green, int blue) {
  //Sets the ledBuffer[led] to the specific colour
  if(red > MaxColourValue) red = MaxColourValue;
	if(green > MaxColourValue) green = MaxColourValue;
	if(blue > MaxColourValue) blue = MaxColourValue;
  _ledColourBuffer[led][RedLed] = red;
  _ledColourBuffer[led][GreenLed] = green;
  _ledColourBuffer[led][BlueLed] = blue;
}

void ShiftBar::BufferLedColourNormalised(int led, int red, int green, int blue) {
  //Sets the ledBuffer[led] to the specific colour
  if(red > MaxNormalisedColourValue) red = MaxNormalisedColourValue;
	if(green > MaxNormalisedColourValue) green = MaxNormalisedColourValue;
	if(blue > MaxNormalisedColourValue) blue = MaxNormalisedColourValue;
  BufferLedColour(led, GetGammaCorrectedBrightness(red), GetGammaCorrectedBrightness(green), GetGammaCorrectedBrightness(blue));
}

void ShiftBar::BufferLedCommand(int led, int redCommand, int greenCommand, int blueCommand) {
	  //Sets the ledBuffer[led] to the specific colour
  if(redCommand > MaxCommandValue) redCommand = MaxCommandValue;
	if(greenCommand > MaxCommandValue) greenCommand = MaxCommandValue;
	if(blueCommand > MaxCommandValue) blueCommand = MaxCommandValue;
  _ledCommandBuffer[led][RedLed] = redCommand;
  _ledCommandBuffer[led][GreenLed] = greenCommand;
  _ledCommandBuffer[led][BlueLed] = blueCommand;
}
int ShiftBar::GetGammaCorrectedBrightness(int brightness)
{
  //TODO Check length of table
  return gammaCorrectionTable[brightness];  
}

void ShiftBar::WriteBufferToLEDArray()
{
//write buffer array to LED hardware across 
//Writes both command and image
  for (int i = 0; i < _numberLeds; i++) {
    _ledColourCurrent[i][RedLed] = _ledColourBuffer[i][RedLed];
    _ledColourCurrent[i][GreenLed] = _ledColourBuffer[i][GreenLed];
    _ledColourCurrent[i][BlueLed] = _ledColourBuffer[i][BlueLed];
    SendDataPacket(_ledColourBuffer[i][RedLed],_ledColourBuffer[i][GreenLed],_ledColourBuffer[i][BlueLed]);
  }
  LatchToRegisters();

  for (int i = 0; i < _numberLeds; i++) {
    SendCommandPacket(_ledCommandBuffer[i][RedLed],_ledCommandBuffer[i][GreenLed],_ledCommandBuffer[i][BlueLed]);
    //SendCommandPacket(120,100,100);
  }
  LatchToRegisters();
}

void ShiftBar::SendDataPacket(int red, int green, int blue)
{
//Sends data packet to LED driver chips 
// Write to PWM control registers
  SendPacket(B00, red, green, blue);
}

void ShiftBar::SendCommandPacket(int redCommand, int greenCommand, int blueCommand)
{
  //Write shiftBright command i.e. relative brightness
  SendPacket(B01, redCommand,greenCommand,blueCommand);
}

void ShiftBar::SendPacket(int commandMode, int redCommand, int greenCommand, int blueCommand)
{
//Sends command packet to LED driver chips 
// Write to PWM control registers
  SPDR = commandMode << 6 | blueCommand>>4;
  while(!(SPSR & (1<<SPIF)));
  SPDR = blueCommand<<4 | redCommand>>6;
  while(!(SPSR & (1<<SPIF)));
  SPDR = redCommand << 2 | greenCommand>>8;
  while(!(SPSR & (1<<SPIF)));
  SPDR = greenCommand;
  while(!(SPSR & (1<<SPIF)));
}  
  

void ShiftBar::LatchToRegisters() {
  // Latch values into the LED driver chips PWM registers

  //delayMicroseconds(1);
  //LATPORT += (1 << LATPIN);
  //ENAPORT += (1 << ENAPIN);
  //delayMicroseconds(10);
  //ENAPORT &= ~(1 << ENAPIN);
  //LATPORT &= ~(1 << LATPIN);
  
  delayMicroseconds(LatchDelay);
  digitalWrite(_latchpin,HIGH); // latch data into registers
  delayMicroseconds(LatchDelay);
  digitalWrite(_latchpin,LOW);
}
