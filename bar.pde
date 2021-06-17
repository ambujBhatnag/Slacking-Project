import processing.serial.*;
Serial myPort;
int serial_string;
int[] serial_array;
int serial_number = 0;
int last_serial_number = 0;
int state = 1;

int[][] target_array = {{250,300},{400,800},{600,700},{900,1023}}; //target array specifically for potentiometer
boolean target_force_flag = false;
int target_force_start_time;
int target_force_end_time;

void setup() {
  frameRate(60);
  size(1024,768);
  //new Serial(this, "/dev/cu.usbmodem14101", 9600).bufferUntil(ENTER); //use if on mac
  background(0,0,0);
  new Serial(this, "COM3", 9600).bufferUntil(ENTER);
}

void draw() {
  background(0,0,0);
  //while (myPort.available() > 0) {
  //  String inByte = myPort.readString();
  //  println(inByte);
  //}
  //int scale_height = Integer.valueOf(myPort.readString());
  switch(state){
    case 1: //set max (3x)
      println("State 1: Callibration - ");
      //st1_callibration();
      state = 2;
      break;
    case 2:
      st2_trueVal();
      println("State 2: true values - " + serial_number);
      break;
    case 3:
      println("State 3!!");
    case 4:
  }
  
  //try {
  //  last_serial_number = serial_number;
  //  serial_number = serial_array[0];
  
  //}
  //catch (NullPointerException exception) {
  //  serial_number = 0;
  //}
  
  //rect(width/2 - 25,height,50, -(serial_number * height*3/4 / 1023) );
  
}

void serialEvent(Serial myPort) {  // serial data pushed to buffer
  serial_array = int(splitTokens(myPort.readString()));
  //println(serial_array);
  //println(myPort.readString());
  //println("test");
  //serial_string = Integer.valueOf(myPort.readString()); // save serial data as vector [0]= throttle [1]= force
}

void st1_callibration() { //must be developed for force sensor
  // smoothing filter on arduino or in processing
  
  //max calibration test!
  println("do max");
  rect(width/2 - 25, height,50, -(serial_number * height*3/4 / 1000) ); //scale must be changed for moment sensor, 
  state = 2;
  print("STATE: " + state);
  //must go to release state!
}

void st2_trueVal() {
  last_serial_number = serial_number;
  try {
    serial_number = serial_array[0];
  }
  catch (NullPointerException exception) {
    serial_number = 0;
  }
  
  rect(width/2 - 25,height,50, -(serial_number * height*3/4 / 1023) ); //convert to integer; max replaces 1023
  
  if ( (!target_force_flag) &&(serial_number >= target_array[0][0]) && (serial_number <= target_array[0][1]) ) {
    println("TARGET POSITION REACHED: " + serial_number);
    target_force_start_time = millis();
    target_force_flag = true;
  }
  
  if ( target_force_flag && (millis() - target_force_start_time >= 300) ) {
    state = 3;
    println("STATE CHANGED FROM 2 TO 3");
  }
  
  if ( (target_force_flag) && ( (serial_number < target_array[0][0]) || (serial_number > target_array[0][1])) ) {
    println("OUT OF TARGET POSITION: " + serial_number);
    target_force_flag = false;
  }
  
}

void reset() {
  
}
