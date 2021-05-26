import processing.serial.*;
Serial myPort;
int serial_string;
int[] serial_array;
int serial_number;
void setup() {
  frameRate(60);
  size(1024,768);
  //new Serial(this, "/dev/cu.usbmodem14101", 9600).bufferUntil(ENTER); //use if on mac
  background(0,0,0);
  new Serial(this, "COM3", 9600).bufferUntil(ENTER);
}

void draw() {
  background(0,234,0);
  //while (myPort.available() > 0) {
  //  String inByte = myPort.readString();
  //  println(inByte);
  //}
  //int scale_height = Integer.valueOf(myPort.readString());
  try {
    serial_number = serial_array[0];
  
  }
  catch (NullPointerException exception) {
    serial_number = 0;
  }
  
  rect(width/2 - 25,height,50, -(serial_number * height*3/4 / 1023) );
  
}

void serialEvent(Serial myPort) {  // serial data pushed to buffer
  serial_array = int(splitTokens(myPort.readString()));
  println(serial_array);
  //println(myPort.readString());
  //println("test");
  //serial_string = Integer.valueOf(myPort.readString()); // save serial data as vector [0]= throttle [1]= force
}
