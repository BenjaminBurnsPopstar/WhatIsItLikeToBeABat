/* What is it like to be a Bat? - Benjamin Burns - Programming Interactive Systems - Assignment 2
 
 with code to drawInsect() based on a template sketch by Matt Pearson, in which noise is added to a spiral shape,
 from the book 'generative art: a practical guide to using processing' */

import processing.serial.*;        // Import Processing serial library
Serial myPort;                     // The serial port

import processing.sound.*;         // Import Processing Sound Library

SoundFile ambience;                // sound file defined as ambience

SinOsc sine;                       // Create object from SinOsc class
Env env;                           // Create object from Env class

float BAT;                         // Variable for mapping incoming distance data to frequency
float nextnote;                    // variable so that the frequency can be altered, varying even as distance remains constant

float attackTime = 0.02;           // Define envelope characteristics
float sustainTime = 0.01;
float sustainLevel = 0.01;
float releaseTime = 0.1;

float blip = 0;                    // variable which reads changes from incoming serial data
float change;                      // variable to store data changes from blip

float xdps, ydps, zdps;            // variables for raw gyroscope data converted to degrees per second
float xpos, ypos;                  // variables for mapping converted gyroscope x and y axis data to location of the insect
float zpan;                        // variable for mapping converted gyroscope z axis data to pan of SinOsc

float hunt;                        // variable which modifies scale, zooming in and out on the insect
float xPan = 960;                  // centre x, y co-ordinates
float yPan = 540;

int _num = 3;                      // variable for the number of overlapping insects to draw, can be increased for denser texture but takes more processing power
float radius;                      // variable for radius of the insect

void setup() {
  size(1920, 1080, P2D);           // display size, P2D renderer for speed
  smooth(4);                       // P2D defaults to smooth(2), smooth(4) improves image quality
  printArray(Serial.list());       // Prints available serial ports
  myPort = new Serial(this, Serial.list()[1], 9600);      // sets serial port as the 2nd port on the list
  myPort.bufferUntil('\n');        // buffer until line break
  sine = new SinOsc(this);         // set up sine wave oscillator and envelope
  env  = new Env(this);
  ambience = new SoundFile(this, "Bats 5th Speed.wav");    // points to the sound file to be played
  ambience.loop();                 // sound file will play over and over again
}

void draw() {
  translate(width/2, height/2);    // zoom towards the centre of the screen
  scale(hunt);                     // set zoom scale according to hunt variable
  translate(-xPan, -yPan);         // preventing point 0,0 from occupying the centre of the screen

  nextnote = BAT - random(200);    // add a random frequency jump to the note, so that when distance remains stable there is still a step-like quality to the sound

  background(0);                   // black background

  if (blip != change) {            // Run this code if blip is not equal to change, and each time blip changes store it in change
    change = blip;                 // So the following code will only trigger when blip changes, which is each time serial data comes in
    drawInsect();                  // draw an insect according to parameters defined in void drawInsect() below
    sine.play();                   // play a sine wave
    sine.amp(0.2);                 // set amplitude
    sine.freq(nextnote);           // frequency set according to distance (BAT) with additional randomisation as defined by variable (nextnote)
    sine.pan(zpan);                // pan altered according to gyroscope z axis rotation
    env.play(sine, attackTime, sustainTime, sustainLevel, releaseTime);    // envelope calls on global envelope parameters

    for (int i = 0; i <= 600; i ++) {      // for loop which draws 600 small ellipses for background texture
      ellipse(random(1920), random(1080), 0.5, 0.5);
      fill(140);
    }
  }
}

void serialEvent(Serial myPort) {
  String myString = myPort.readStringUntil('\n');
  myString = trim(myString);
  int data[] = int(split(myString, ','));

  if (data.length > 1) {
    print("X: " + data[0] + "\t");        // print out the values
    print("Y: " + data[1] + "\t");
    print("Z: " + data[2] + "\t");
    print("BAT: " + data[3] + "\t");

    println();                            // add a linefeed after all the sensor values are printed:

    blip ++;                              // increase the value of blip each time serialEvent runs

    xdps = data[0] * 16 / 1000;           // convert raw gyroscope data to degrees per second
    ydps = data[1] * 16 / 1000;
    zdps = data[2] * 16 / 1000;
    xpos = map(xdps, -530, 530, 1920, 0) + random(-15, 15);  // map dps to width and height of the screen, with randomisation so that the insect is not static
    ypos = map(ydps, -530, 530, 1080, 0) + random(-15, 15);
    zpan = map(zdps, -530, 530, -1.0, 1.0);                  // map dps to SinOsc pan
    BAT  = map(data[3], 0, 70, 5500, 4000);                  // map ultrasonic sensor distance data to frequency
    hunt = map(data[3], 0, 70, 6, 1);                        // map distance data to zoom
  }
  myPort.write("A");                                         // send a byte to ask for more data
}

void drawInsect() {
  for (int i=0; i<_num; i++) {                                      // Loop creates layers of Insect
    stroke(random(140, 255), random(140, 255), random(140, 255), 90);      // Randomised Values create bright coloured flicker, Transparent Stroke
    strokeWeight(0.3);                                               // thin lines
    radius = 1;                                                      // small radius
    float x, y;
    float centX = xpos;
    float centY = ypos;
    float lastx = 0;
    float lasty = 0;
    float radiusNoise = random(100);                                    // 100 possible random values of radiusNoise

    for (float ang = 0; ang <= 720; ang += 1) {                         // Two 360-degree Loops, incrementing by 1 Degree
      radius += 0.05;                                                   // Radius increments to create Spiral
      radiusNoise += 0.05;                                              // Add noise to the Radius, creating Noisy Spiral
      float thisRadius = radius + (noise(radiusNoise) * 200) - 100;     // Radius incrementation plus noise, incrementing at a rate of 0.05
      // multiplied by 200 to create a large variance
      // - 100 to keep the shape compact
      float rad = radians(ang);                                         // Converts from Degrees to Radians
      x = centX + (thisRadius * cos(rad));                              // Calculate the coordinates relative to the angle
      y = centY + (thisRadius * sin(rad));
      if (lastx > 0) {
        line(x, y, lastx, lasty);                                       // line is drawn forward from x, y to x, y incrementally, referring back to lastx and lasty
      }                                                                 // in order to draw line from point to point
      lastx = x;
      lasty = y;
    }
  }
}
