// TEST of the SD library
// write the string "Testing text 1, 2 ,3..." in the file "test.txt" on the SD

#include <SD.h>
#include <SPI.h>

File myFile;

int pinCS = 10; // Pin 10 on Arduino Uno

void setup() {
    
  pinMode(pinCS, OUTPUT);
  pinMode(8, OUTPUT);  // led
  
  //blink 3 times at startup
  blink(3);
  delay(1000);
  
  // SD Card Initialization
  if (SD.begin()) blink(4); //blink 4 times => init OK
  else { //error
    blink(5); //blink 5 times => init failed
    return;
  }
  
  // Create/Open file 
  myFile = SD.open("test.txt", FILE_WRITE);
  
  // if the file opened okay, write to it:
  if (myFile) {
    // Write to file
    myFile.println("Testing text 1, 2 ,3...");
    myFile.close(); // close the file
    delay(1000);
    blink(6); //blink 6 times => file open OK + write OK
  }
  // if the file didn't open, print an error:
  else { delay(1000); blink(7);} //blink 7 times => file failed
  
}

void loop() {
  // empty
}

void blink(int n){
  for(int i =0; i<n; i++){
  digitalWrite(8, LOW);
  delay(500);
  digitalWrite(8, HIGH);
  delay(500);
  }
}
