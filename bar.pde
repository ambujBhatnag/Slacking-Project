import processing.serial.*;

//general global variables
Serial myPort;
int serial_string;
int[] serial_array;
int fitted_number = 0;
int last_raw_serial = 0;
int raw_serial = 0;
final float factor = 0.75;
int state = 1; //initial state
int reset_next_state =1; //reset after every reset call
final float height_factor = 0.75;

//state 1 - callibration global variables
final int max_bounds = 20; //determines max lower bounds and max upper bounds for callibration state
boolean recall_bool = true; //recall_bool
int callibration_iteration = 1;
int upper_bound;
int lower_bound;
int temp_max;
int max;
Queue state_1_vals;
int bound_times;


//state 2 - true values global variables
int[][] target_array = {{250,300},{400,800},{600,700},{900,1023}}; //target array specifically for potentiometer
//work on fractions for moment sensor and use scaling for the measurements; use mapping 0.89 to 0.91, that large of a range
boolean target_force_flag = false;
int target_force_start_time;
int target_force_end_time;


//state 3 - slacking global variables
Queue state_3_vals;

//state 4 - reset global variables
void setup() {
  frameRate(60);
  size(1024,768);
  //new Serial(this, "/dev/cu.usbmodem14101", 9600).bufferUntil(ENTER); //use if on mac
  background(0,0,0);
  new Serial(this, "COM3", 9600).bufferUntil(ENTER);
  
  state_1_vals = new Queue(6);
  state_3_vals = new Queue(15); // might be less values
}

void draw() {
  background(0,0,0);
  //add
  
  
  //alpha filter implementation, redefine the serial number
  alpha_filter();
  
  if (state == 1) {
    state_1_vals.add(fitted_number);
  }
  else if (state == 3) {
    state_1_vals.add(fitted_number);
  }

  switch(state){
    case 1: //set max (3x)
      //println("State 1: Callibration - ");
      st1_callibration();
      
      break;
    case 2:
      st2_trueVal();
      println("State 2: true values - " + fitted_number);
      break;
    case 3:
      println("State 3!!");
    case 4:
      if (reset()) { state = reset_next_state;}
      
      
  }
  
  //try {
  //  last_raw_serial = fitted_number;
  //  fitted_number = serial_array[0];
  
  //}
  //catch (NullPointerException exception) {
  //  fitted_number = 0;
  //}
  
  //rect(width/2 - 25,height,50, -(fitted_number * height*height_factor / 1023) );
  
}
void alpha_filter() {
  try {
   // if (raw_serial != 0) {
      last_raw_serial = fitted_number;
      raw_serial = serial_array[0];
    //}
    
  }
  catch (NullPointerException exception) {
    raw_serial = 0;
  }
  
  float fitted_number = last_raw_serial + factor*(raw_serial - last_raw_serial);
  this.fitted_number = (int)fitted_number;
}

void serialEvent(Serial myPort) {  // serial data pushed to buffer
  serial_array = int(splitTokens(myPort.readString()));
  //println(serial_array);
  //println(myPort.readString());
  //println("test");
  //serial_string = Integer.valueOf(myPort.readString()); // save serial data as vector [0]= throttle [1]= force
  
}

void st1_callibration() {
  println("State 1: Callibration - " + callibration_iteration);
  println("MAX: " + max);
  if ( callibration_iteration != 1) {
    rect(width/2 - 25, height, 50, -(fitted_number * height*height_factor/max)  ) ; //should be fitted_number, not raw_serial
  }
  
  if ( (raw_serial > temp_max) || (raw_serial < lower_bound) ){
      temp_max = raw_serial;
      bound_times = millis();
      println("BOUND TIMES: " + bound_times);
      upper_bound = temp_max + max_bounds;
      lower_bound = temp_max - max_bounds;
    }
    
    if ( (millis() - bound_times >= 4000) && (raw_serial <= upper_bound) && (raw_serial >= lower_bound) ) {
      if (temp_max > max) {
        max = temp_max;
      }
      state = 4;
      reset_next_state = 1;
      println("MAX ACHEIVED: " +  max);
      callibration_iteration += 1;
      upper_bound = 0;
      lower_bound = 0;
      temp_max = 0;
      bound_times = millis();
      
    }
    
    if (callibration_iteration == 4) {
      //state = 2;
      println("MAX FOUND: " + max);
      exit();
    }
  
  //if (recall_bool) {
  //  temp_max = state_1_vals.max();
  //  max = temp_max;
  //  upper_bound = temp_max + max_bounds;
  //  lower_bound = temp_max - max_bounds;
  //  bound_times = millis();
  //  recall_bool = false;
  //}
  
  //if (fitted_number > upper_bound){
  //  recall_bool = true;
  //}
  //else if (millis() - bound_times >= 4000) {
  //  if (state_1_vals.max() > max) {
  //    max = state_1_vals.max();
  //  }
  //  callibration_iteration +=1;
    
  //  if (callibration_iteration == 3) { exit();}//state=2;}
  //  state = 4;
  //  reset_next_state = 1;
  //  println("new max acheived!");
  //  println(max);
    
  //}
  
  
  
  //state = 2;
  //print("STATE: " + state);
  //must go to release state!
}


void st2_trueVal() {
  rect(width/2 - 25,height,50, -(fitted_number * height*height_factor / 1023) ); //convert to integer; max replaces 1023
  
  if ( (!target_force_flag) &&(fitted_number >= target_array[0][0]) && (fitted_number <= target_array[0][1]) ) {
    println("TARGET POSITION REACHED: " + fitted_number);
    target_force_start_time = millis();
    target_force_flag = true;
  }
  
  if ( target_force_flag && (millis() - target_force_start_time >= 300) ) {
    state = 3;
    println("STATE CHANGED FROM 2 TO 3");
  }
  
  if ( (target_force_flag) && ( (fitted_number < target_array[0][0]) || (fitted_number > target_array[0][1])) ) {
    println("OUT OF TARGET POSITION: " + fitted_number);
    target_force_flag = false;
  }
  
}

boolean reset() {
  println("RESET THE BAR!");
  if (fitted_number == 0) {
    return true;
  } else {
    return false;
  }
  
}




class Queue {
  private IntList list;
  int size;
  
  Queue(int size) {
    list = new IntList(size);
    this.size = size;
  }
  
  int size() {
    return list.size();
  }
  
  void add(int value) {
    maintain_size();
    list.reverse();
    if (list.size() == this.size) {
      list.remove(list.size() -1); 
    }
    list.reverse();
    list.append(value);
  }
  
  int peek() {
    return list.get(list.size() -1);
  }
  
  IntList toList() {
    list.reverse();
    IntList list1 = list.copy();
    list.reverse();
    return list1;
  }
  
  int max() {
    return list.max();
  }
  private void maintain_size() {
    if (list.size() > this.size) {
      list.reverse();
      while (list.size() > this.size) {
        list.remove(list.size() - 1);
      }
      list.reverse();
    }
  }
  
  String print() {
    String returnString = "";
    list.reverse();
    for (int i = 0; i < this.size; i++) {
      returnString += list.get(i);
      if (i != this.size -1) {
        returnString += ", ";
      }
    }
    list.reverse();
    return returnString;
  }
}
