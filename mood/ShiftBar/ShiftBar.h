/*
  ShiftBar.h - Library for comunicating with shifbars and compatible devices.
  Created by Chris Heazlewood, November 1, 2011.
  Released into the public domain.
*/

#ifndef ShiftBar_h
#define ShiftBar_h

#include "Arduino.h"

class ShiftBar
{
  public:
	ShiftBar(int clockpin, int enablepin, int latchpin, int datapin, int numberLeds);
	void SetNumberLeds(int numberLeds);
	void BufferAllLedsColour(int red, int green, int blue);
	void BufferLedColour(int led, int red, int green, int blue);
	void BufferLedCommand(int led, int redCommand, int greenCommand, int blueCommand);
	void BufferAllLedsColourNormalised(int red, int green, int blue);
	void BufferLedColourNormalised(int led, int red, int green, int blue);
	void WriteBufferToLEDArray();
	void SendDataPacket(int red, int green, int blue);
	void SendCommandPacket(int redCommand, int greenCommand, int blueCommand);
	void LatchToRegisters();
  static int MaxColourValue;
  static int MaxNormalisedColourValue;
  static int MaxCommandValue;
  
	
  private:
	int _numberLeds;
	int _clockpin; // CI
	int _enablepin; // EI
	int _latchpin; // LI
	int _datapin; // DI
	int GetGammaCorrectedBrightness(int brightness);
  void SendPacket(int commandMode, int redCommand, int greenCommand, int blueCommand);
  //int* LedBuffer[3];
	//int* LedCurrent[3];
};
#endif