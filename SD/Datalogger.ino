
// Arduino scetch to read the sensor output (connected to PC5) and write
// the result to a text file "datalog.txt" on the SD.

#include <SPI.h>
#include <SD.h>

const int chipSelect = 10; //uno

int n =0;  // sample No
float voltage; // sample value

void setup(){
  // Open serial communications and wait for port to open:
  Serial.begin(9600);

  Serial.print("Initializing SD card...");

  // see if the card is present and can be initialized:
  if (!SD.begin(chipSelect)) {
    Serial.println("Card failed, or not present");
    // don't do anything more:
    return;
  }
  Serial.println("card initialized.");
}

void loop(){
  // make a string for assembling the data to log:
  String dataString = "";
  
  dataString += String(n++); // append sample number to the string
  
  dataString += ",";   append a comma to the string
  
  // read the sensor and append to the string:
  int sensor = analogRead(5); // read PC5
  voltage = (float) (sensor * 3.3)/1024; // Convert analog Value
  dataString += String(voltage);
  

  // open the file. 
  File dataFile = SD.open("datalog.txt", FILE_WRITE);

  // if the file is available, write to it:
  if (dataFile) {
    dataFile.println(dataString);
    dataFile.close();
    // print to the serial port too:
    Serial.println(dataString);
  }
  
  // if the file isn't open, pop up an error:
  else {
    Serial.println("error opening datalog.txt");
  }
  
  delay(3000);  // wait 3 secondes
}









