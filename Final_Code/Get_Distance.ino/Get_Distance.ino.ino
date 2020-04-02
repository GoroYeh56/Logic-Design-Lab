//Arduino : Get distance => dis[7:0] to FPGA board.
//FPGA : Compute PID value , and send back to Arduino. (PID_total [8:0]).
//Arduino : Then write Servo motor to certain angle.

/*SHARP GP2Y0A21YK0F IR sensor with Arduino and SharpIR library example code. More info: https://www.makerguides.com */
// Include the library:
#include <SharpIR.h>
#include <Wire.h>
#include <Servo.h>
#include <math.h>
// Define model and input pin:
#define Analog_in A0
#define model 1080
//define dis[5:0] send to FPGA.
#define dis0 2
#define dis1 3
#define dis2 4
#define dis3 5
#define dis4 6
#define dis5 7
//define PID[8:0] to write Motor.
#define PID0 22
#define PID1 24
#define PID2 26
#define PID3 28
#define PID4 30
#define PID5 32
#define PID6 34
#define PID7 36
#define PID8 38
#define measure_period 100 // every 100ms get distance once. (100times a second.)
/* Model :
  GP2Y0A02YK0F --> 20150
  GP2Y0A21YK0F --> 1080
  GP2Y0A710K0F --> 100500
  GP2YA41SK0F --> 430
*/
SharpIR mySensor = SharpIR(Analog_in, model);  // Create a new instance of the SharpIR class:
Servo myservo;                                // create servo object to control a servo, later attatched to D9
int distance;                                 // Create variable to store the distance.(cm)
boolean dis[6];  //6bit distance.
boolean PID[9];  //9bit PID_total
int PID_total;
float time=0;
boolean test[9] = {1,1,1,1,0,0,0,0,0};
void setup() {
  // Begin serial communication at a baudrate of 9600:
  Serial.begin(9600);
  pinMode(dis0,OUTPUT);
  pinMode(dis1,OUTPUT);
  pinMode(dis2,OUTPUT);
  pinMode(dis3,OUTPUT);
  pinMode(dis4,OUTPUT);
  pinMode(dis5,OUTPUT);

  pinMode(PID0,INPUT);
  pinMode(PID1,INPUT);
  pinMode(PID2,INPUT);
  pinMode(PID3,INPUT);
  pinMode(PID4,INPUT);
  pinMode(PID5,INPUT); 
  pinMode(PID6,INPUT);
  pinMode(PID7,INPUT);
  pinMode(PID8,INPUT);

//  myservo.attach(9);  // attaches the servo on pin 9 to the servo object
//  myservo.write(0); //Put the servco at angle 0, so the balance is in the middle
  time = millis();  
  
}

void loop() {
  if (millis() > time + measure_period){
        //update current time.
        time = millis();      
        
        // Get a distance measurement and store it as distance_cm:
        distance = mySensor.distance();
        //Change to binary and send to FPGA.
        if(distance>=33 && distance <36){distance = distance-3;}
        if(distance>=36 && distance <40){distance = distance-3;}
        else if(distance>=40){distance = distance-10;}
        if(distance<2)          convertDecToBin(distance,dis,1); // 1 bit.
        else if(distance<4)     convertDecToBin(distance,dis,2); // 2 bit.
        else if(distance<8)     convertDecToBin(distance,dis,3); // 3 bit.
        else if(distance<16)    convertDecToBin(distance,dis,4); // 4 bit.
        else if(distance<32)    convertDecToBin(distance,dis,5); // 5 bit.
        else                    convertDecToBin(distance,dis,6); // 6 bit..
        SendDistance(dis);
//        for(int i=5; i>=0; i--)
//        Serial.print(dis[i]);
//        Serial.print(" ");
//        
//        //Write servo motor. First Read input from 
//         Get_PID_total();
//         PID_total = convertBinToDec(PID, 9); //9 bit.
//         //Define Boundaries
//         if(PID_total < 20){PID_total = 20;}
//         if(PID_total >160) {PID_total = 160; }         
//         myservo.write(PID_total);  

        // Print the measured distance to the serial monitor: (For debugging)
        Serial.print("Distance: ");
        Serial.print(distance);
        Serial.println(" cm ");  
        for(int i=0; i<=8; i++){
           Serial.print(PID[i]); //clear array.
        }
      
        Serial.print(" PID: ");
        Serial.println(PID_total);
        for(int i=0; i<=5; i++)
            dis[i] = 0; //clear array.
  }
}
/*
The following function convert any int from 0-255 to binary.
You need to pass the int as agrument.
You also need to pass the 7bit array of boolean
*/
void convertDecToBin(int Dec, boolean Bin[], int n) { //n bit.
  for(int i = n-1 ; i >= 0 ; i--) { //i from 5 to 0.
    if(Dec!=1){
      if((Dec%2)==1) { //if Dec mod 2 == 1 
        Bin[(n-1)-i] = 1; //Let Binary first bit (0) = 1.
      } else { //to zero.
        Bin[n-1-i] = 0;
      }
      Dec = Dec/2;
    }
    else{
      Bin[n-1-i] = 1;
    }
  }
}

void SendDistance(boolean dis[]){
    if(dis[0]==1) digitalWrite(dis0 , HIGH);
    else digitalWrite(dis0, LOW);
    if(dis[1]==1) digitalWrite(dis1 , HIGH);
    else digitalWrite(dis1, LOW);
    if(dis[2]==1) digitalWrite(dis2 , HIGH);
    else digitalWrite(dis2, LOW);    
    if(dis[3]==1) digitalWrite(dis3 , HIGH);
    else digitalWrite(dis3, LOW);
    if(dis[4]==1) digitalWrite(dis4 , HIGH);
    else digitalWrite(dis4, LOW);
    if(dis[5]==1) digitalWrite(dis5 , HIGH);
    else digitalWrite(dis5, LOW);      
}

int PID_value[9];
void Get_PID_total(){ //digital read and convert to decimal.
    PID_value[0] = digitalRead(PID0);
    PID_value[1] = digitalRead(PID1);
    PID_value[2] = digitalRead(PID2);
    PID_value[3] = digitalRead(PID3);
    PID_value[4] = digitalRead(PID4);
    PID_value[5] = digitalRead(PID5);  
    PID_value[6] = digitalRead(PID6);
    PID_value[7] = digitalRead(PID7);
    PID_value[8] = digitalRead(PID8);      
    
    if(PID_value[0]==HIGH) PID[0] = 1;
    else PID[0] = 0;
    if(PID_value[1]==HIGH) PID[1] = 1;
    else PID[1] = 0;
    if(PID_value[2]==HIGH) PID[2] = 1;
    else PID[2] = 0;
    if(PID_value[3]==HIGH) PID[3] = 1;
    else PID[3] = 0;
    if(PID_value[4]==HIGH) PID[4] = 1;
    else PID[4] = 0;      
    if(PID_value[5]==HIGH) PID[5] = 1;
    else PID[5] = 0;
    if(PID_value[6]==HIGH) PID[6] = 1;
    else PID[6] = 0;
    if(PID_value[7]==HIGH) PID[7] = 1;
    else PID[7] = 0;
    if(PID_value[8]==HIGH) PID[8] = 1;
    else PID[8] = 0;           
}

/*
This following function will convert any 9 bit array of boolean to a Decimal number.
you need to pass an boolean array of 8 bits
function return a int
*/
int ReturnInt;
int convertBinToDec(boolean Bin[], int n) {
   ReturnInt = 0;
  for (int i = 0; i < n; i++) {
//      Serial.print(ReturnInt);
//      Serial.print(" ");
//      Serial.println(pow(2,i));
       ReturnInt += Bin[i]*pow(2,i);
    }
//  Serial.println("Done");
  return ReturnInt;
}
