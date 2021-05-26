
const int potPin = A0;
int pot_output;
int value;

void setup() {
  // initialize digital pin LED_BUILTIN as an output.
  pinMode(potPin, INPUT);
  Serial.begin(9600);
}

// the loop function runs over and over again forever
void loop() {
  value = analogRead(potPin);
  Serial.println(value);
  Serial.write('\t'); 
}
