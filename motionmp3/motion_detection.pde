#include <MP3Trigger.h>
MP3Trigger trigger;

//approx seconds
int StartupDelay = 2;
int DetectionDelay = 10;

int SleepDelay = 500;

int alarmPin = 0;
int alarmValue = 0;
int ledPin = 11;
int mp3TriggerPin = 8;
int randomSeedPin = 5;

int volumeUpPin = 7;
int volumeDownPin = 6;
byte volumeValue = 0;
boolean volUpTriger;
boolean volDownTriger;
int MaxVolume = 1;
int MinVolume = 100;

int serialSpeed = 38400;

int alarmTriggerValue = 100;

int NumberofTracks;
String MP3TriggerVersion;

void setup () {
 
  //Serial.begin (9600);
  Serial.begin (serialSpeed);
  
  //Serial.print ("serial speed: ");
  //Serial.println (serialSpeed, DEC);
  

  pinMode(ledPin, OUTPUT);  
  pinMode(alarmPin, INPUT);
  pinMode(volumeDownPin, INPUT);
  pinMode(volumeUpPin, INPUT);
  
  //start serial communication with the trigger (over Serial)
  trigger.setup();

  GetMP3Status();
  GetNumberofTracks();
  SetVolume(volumeValue);
  
  //Allow PR to warm up    
  SleepDetection(StartupDelay);
}

void loop (){
  //Serial.println ("loop");
  boolean volumeChanged = MaintainVolume();
  //Serial.print("volume changed? ");
  //Serial.println(volumeChanged, DEC);
  
  if(volumeChanged == false)
  {
    //Read PIR
    alarmValue = analogRead(alarmPin);
    
    //Serial.print ("PIR Delta value - ");
    //Serial.println (alarmValue, DEC);
     
    //Check if alert should be thrown
    if (alarmValue < alarmTriggerValue){
      
      //Alert moton detected
      AlertMotonDetected(); 
      
      //Sleep to delay retrigger
      SleepDetection(DetectionDelay);
    }
    
    //necessary to receive signals from trigger
    //trigger.update();
    
    //main loop delay
    delay(SleepDelay);
  
    }
}


//sets the volume on the mp3 trigger.

boolean MaintainVolume() {
 //Serial.println ("MaintainVolume function");
 volUpTriger = digitalRead(volumeUpPin);
 volDownTriger = digitalRead(volumeDownPin);
 //Serial.print("volTriger down,up - ");
 //Serial.print(volDownTriger, DEC);
 //Serial.print(", ");
 //Serial.println(volUpTriger, DEC);
 
  if(volUpTriger == false | volDownTriger == false)
  {
  
    if(volUpTriger == false)
    {
      //Serial.print ("Volume up to ");
      volumeValue--;
    }
    else
    {
      //Serial.print ("Volume down to ");
      volumeValue++;
    }
    
    volumeValue = constrain(volumeValue,MaxVolume,MinVolume);
    //Serial.println (volumeValue, DEC);
    
    SetVolume(volumeValue);
  }
  
  //return if volume changed
  return not(volUpTriger & volDownTriger);
  
}  

//Sleep the process,approx seconds (not accurate time)
void SleepDetection(int seconds) {
  for(int iseconds=0; iseconds<seconds;iseconds++)
  {
     for(int brightness=0; brightness<100; brightness++) {
       analogWrite(ledPin,brightness);
       delay(10);
     }
     delay(50);
     for(int brightness=100; brightness>0; brightness--) {
       analogWrite(ledPin,brightness);
       delay(10);
     }
     digitalWrite(ledPin,LOW);
     delay(250);
   }
}

//Alerts motion detected
void AlertMotonDetected() {
  
 TriggerPlayBack();
  
 for(int i=0; i<2; i++) {
   digitalWrite(ledPin,HIGH);
   delay(100);
   digitalWrite(ledPin,LOW);
   delay(100);
 }
}


void GetMP3Status()
{
  //Serial.println("getting status");
  FlushSerial();
  Serial.write('S');
  Serial.write('0'); //Version
  
  char serialData[128];
  //memset(MP3vers,'\0',128);
  
  int dataSize = ReadSerial(serialData);
  //Serial.print("dateSize=");
  //Serial.println(dataSize);
 
  if (dataSize > 0) {
    char mp3Version[dataSize - 1];
    for (int i = 0; i < dataSize - 2;i++) {
      mp3Version[i] = serialData[i+1];
    }
    
    String MP3versString = String(mp3Version);
    
    //Serial.print("MP3vers: ");
    //Serial.println(MP3versString);
  }
  else
  {
  //char mp3Version[dataSize - 1];
  }
  //String MP3versString = String(ReadSerial(MP3vers));
}


//get number of tracks
void GetNumberofTracks() {
  FlushSerial();
  Serial.write('S');
  Serial.write('1'); //Number of tracks
  
  char serialData[128];
  //memset(tracks,'\0',128);
  
  int dataSize = ReadSerial(serialData);
  //Serial.print("dateSize=");
  //Serial.println(dataSize);
  //Serial.print("tracks: ");
  //Serial.println(serialData);
    
  if (dataSize > 0) {
    char numberoftracks[dataSize - 1];
    for (int i = 0; i < dataSize - 1;i++) {
      numberoftracks[i] = serialData[i+1];
    }
    
    NumberofTracks = atoi(numberoftracks);
    
    //NumberofTracks
    Serial.print("tracks: ");
    Serial.println(NumberofTracks);
  }
  else {
    NumberofTracks = 0;
  }
   
  //Serial.println(tracks.substring(1));
}

//sets volume on the mp3 trigger and alerts user via LED
//max volume is 0
//above 0x40 is to quiet to be heard
void SetVolume(byte volume) {
  //Set volume on mp3 trigger
 
  Serial.write('v');
  Serial.write(volumeValue);
    
  analogWrite(ledPin,255 - volumeValue);
  delay(5);
  analogWrite(ledPin,0);
  delay(5);
}

void TriggerPlayBack() {
  //start looping TRACK001.MP3
  if(NumberofTracks > 0 )  {
    
    randomSeed(analogRead(randomSeedPin));

    int trackNumber = random(NumberofTracks);
    
    Serial.print("play track: ");
    Serial.println(trackNumber);
    
    trigger.trigger(trackNumber);

    digitalWrite(mp3TriggerPin,LOW);
    delay(50);
    digitalWrite(mp3TriggerPin,HIGH);
    delay(50);
  }  
}

int ReadSerial(char DataBuffer[]) {
 int inByte = 0;         // incoming serial byte
 int dataSize=0;

 memset(DataBuffer,'\0',128);

 //Wait for first byte
 delay(100);
 if (Serial.available() > 0) {
   //wait for data to finish 
   delay(300);
   dataSize = Serial.available();
   //Serial.print("dataSize=");
   //Serial.println(dataSize);
   
   for (int i = 0; i < dataSize; i++){
     DataBuffer[i] = Serial.read();
   }
   
   //Serial.print("received: '");
   //Serial.print(DataBuffer);
   //Serial.println("'");
   FlushSerial();
 }
 
 //Serial.print("scopetest: ");
 //Serial.println(DataBuffer);
 
 return dataSize;
 
}

int FlushSerial() {
 //Wait for first byte
 delay(50);
 if (Serial.available() > 0) {
   Serial.flush();
   delay(50);
 
 }
 
}
