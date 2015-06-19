

#include <Servo.h>

Servo myservo;

bool locked;
uint8_t keycode[4];

void setup() {
  // put your setup code here, to run once:

  Serial.begin(57600);
  
  locked = true;
  
  keycode[0] = 6;
  keycode[1] = 3;
  keycode[2] = 1;
  keycode[3] = 4;
  
  pinMode(1, OUTPUT);
  
  myservo.attach(1);
}

ScratchData lastScratch;

void loop() {
  
  ScratchData thisScratch = Bean.readScratchData(1); 
    
  if (true == validate(&thisScratch)) {

    lastScratch = thisScratch;
    
    Bean.setLed(255,0,0);
    
    lastScratch = thisScratch;
     if (locked) {
      myservo.write(1);  
    }
    else {
      myservo.write(179);  
    }
    locked = !locked;
    Bean.sleep(100);
    Bean.setLed(0,0,0);
    // koniec otwierania i zamykania zamka
  }
}

bool validate( ScratchData *scratch) {

  if (scratch->length == 4) {
    if (scratch->data[0] == keycode[0]) {
      if (scratch->data[1] == keycode[1]) {
        if (scratch->data[2] == keycode[2]) {
          if (scratch->data[3] == keycode[3]) {
            return true;
          }
        }
      }
    }
  }
  return false;
}
