/*Benjamin Burns - Programming Interactive Systems - Assignment 2 - What is it like to be a Bat?

  incorporating code for the HC-SR04 sensor, sourced from Arbi Abdul Jabbaar, here: https://create.arduino.cc/projecthub/abdularbi17/ultrasonic-sensor-hc-sr04-with-arduino-tutorial-327ff6
  and serial example code for the L3G4200D gyroscope, sourced from here: https://github.com/pololu/l3g-arduino
*/

#define echoPin 2                         // pin D2 Arduino to pin Echo of ultrasonic sensor, HC-SR04
#define trigPin 3                         // pin D3 Arduino to pin Trig of ultrasonic sensor, HC-SR04

#include <Wire.h>                         // allows for I2C communication
#include <L3G.h>                          // library for gyroscope, L3G4200D

L3G gyro;                                 // define gyro

long duration;                            // variable for duration of sound wave travel
int distance;                             // variable for measurement of distance
int tempo;                                // variable for the mapping of distance to tempo
long previousMillis;                      // variable which is updated against millis()

void setup() {
  pinMode(trigPin, OUTPUT);               // sets trigPin as an OUTPUT
  pinMode(echoPin, INPUT);                // sets echoPin as an INPUT
  Serial.begin(9600);                     // Serial Communication is starting with baudrate of 9600

  previousMillis = millis();              // previousMillis begins with millis(), at 0

  Wire.begin();                           // I2C communication is starting

  if (!gyro.init())                       // if gyro is not initialised print an error message
  {
    Serial.println("Failed to autodetect gyro type!");
    while (1);
  }

  gyro.enableDefault();
}

void loop() {
  gyro.read();                            // read the gyro

  digitalWrite(trigPin, LOW);             // clears the trigPin condition of Ultrasonic sensor
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);            // sets the trigPin HIGH (ACTIVE) for 10 microseconds
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH);      // reads the echoPin, returns the sound wave travel time in microseconds
  distance = duration * 0.034 / 2;        // calculating the distance, speed of sound divided by 2 (go and back)

  if (distance > 70) {                    // limits the distance to 70cm, this number can be increased depending on the setting
    distance = 70;
  }

  tempo = map(distance, 0, 70, 50, 1000); // maps distance to the variable tempo, 50 - 1000 milliseconds

  if (distance < 70) {                          // only runs if distance is less than 70cm, so that any greater distance does not trigger serial data to send
    if (millis() - previousMillis > tempo) {    // if time elapsed minus previous time is more than tempo, update previous time
      previousMillis = millis();                // and print the raw data from the gyroscope, as well as the variable distance
      Serial.print((int)gyro.g.x);              // with commas between each piece of information, so that the data can be interpreted easily in Processing
      Serial.print(",");
      Serial.print((int)gyro.g.y);
      Serial.print(",");
      Serial.print((int)gyro.g.z);
      Serial.print(",");
      Serial.println(distance);
    }
  }
}
