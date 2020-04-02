 /* PID balance code with ping pong ball and distance sensor sharp 2y0a21
 *  by ELECTRONOOBS: https://www.youtube.com/channel/UCjiVhIvGmRZixSzupD0sS9Q
 *  Tutorial: http://electronoobs.com/eng_arduino_tut100.php
 *  Code: http://electronoobs.com/eng_arduino_tut100_code1.php
 *  Scheamtic: http://electronoobs.com/eng_arduino_tut100_sch1.php 
 *  3D parts: http://electronoobs.com/eng_arduino_tut100_stl1.php   
 */
#include <Wire.h>
#include <Servo.h>



///////////////////////Inputs/outputs///////////////////////
int Analog_in = A0;
Servo myservo;  // create servo object to control a servo, later attatched to D9
///////////////////////////////////////////////////////

//arduino input 9 bit use digital 2~10.
//input A0 distance, use A1 A2 A3 A4 A5 11 12 send to FPGA

////////////////////////Variables///////////////////////
int Read = 0;
int distance =0;
float elapsedTime, time, timePrev;        //Variables for time control
int distance_previous_error, distance_error;
int period = 50;  //Refresh rate period of the loop is 1ms
///////////////////////////////////////////////////////


///////////////////PID constants///////////////////////
float kp=8; //Mine was 8
float ki=0.2; //Mine was 0.2
float kd=2000; //Mine was 3100 
float distance_setpoint = 25;           //Should be the distance from sensor to the middle of the bar in mm
float PID_p, PID_i, PID_d, PID_total;
///////////////////////////////////////////////////////



void setup() {
  //analogReference(EXTERNAL);
  Serial.begin(9600);  
  myservo.attach(9);  // attaches the servo on pin 9 to the servo object
  myservo.write(0); //Put the servco at angle 125, so the balance is in the middle
  pinMode(Analog_in,INPUT);  
  time = millis();
}

void loop() {
//    myservo.write(30);
  if (millis() > time+period)
  {  
    time = millis();    
    distance = get_dist();   
    distance_error = distance_setpoint - distance; 
    if(distance_error <=2 && distance_error >=-2){
      myservo.write(100);
    }
    else{  
        PID_p = kp * distance_error;
        float dist_difference = distance_error - distance_previous_error;     
        PID_d = kd*((dist_difference)/period);
          
        if(-5 < distance_error && distance_error < 5)
        {
          PID_i = PID_i + (ki * distance_error);
        }
        else
        {
          PID_i = 0;
        }
      
        PID_total = PID_p + PID_i + PID_d;  
        Serial.print("PID befor mappeds: ");
        Serial.print(PID_total);
        Serial.print(" ");  
        
        PID_total = map(PID_total, -150,150,0,150);
    //    PID_total /= 10;
        
        if(PID_total < 20){PID_total = 20;}
        if(PID_total >140) {PID_total = 140; } 
      
        myservo.write(PID_total);  
    }
    Serial.print("PID: ");
    Serial.print(PID_total);
    Serial.print(" ");
    Serial.print("Distance: ");
    Serial.println(distance);    
    distance_previous_error = distance_error;
  }
}




//float get_dist(int n)
//{
////  long sum=0;
////  for(int i=0;i<n;i++)
////  {
////    sum=sum+analogRead(Analog_in);
////  }  
////  float adc=sum/n;
////  //float volts = analogRead(adc)*0.0048828125;  // value from sensor * (5/1024)
////  //float volts = sum*0.003222656;  // value from sensor * (3.3/1024) EXTERNAL analog refference
////
////  float distance_cm = 17569.7 * pow(adc, -1.2062);
////  //float distance_cm = 13*pow(volts, -1); 
////  return(distance_cm);
//}
// 
 
 /*
 * Sharp IR (infrared) distance measurement module for Arduino
 * Measures the distance in cm.

 * Watch the video https://youtu.be/GL8dkw1NbMc

 *  * 

Original library: https://github.com/guillaume-rico/SharpIR

Updated by by Ahmad Nejrabi for Robojax.com
on Feb 03, 2018 at 07:34 in Ajax, Ontario, Canada
 * Permission granted to share this code given that this
 * note is kept with the code.
 * Disclaimer: this code is "AS IS" and for educational purpose only.
 * 
 /*
/*




 */
  // Sharp IR code for Robojax.com
#include <SharpIR.h>

#define IR A0 // define signal pin
#define model 1080 // used 1080 because model GP2Y0A21YK0F is used
// Sharp IR code for Robojax.com
// ir: the pin where your sensor is attached
// model: an int that determines your sensor:  1080 for GP2Y0A21Y
//                                            20150 for GP2Y0A02Y
//                                            430 for GP2Y0A41SK   
/*
2 to 15 cm GP2Y0A51SK0F  use 1080
4 to 30 cm GP2Y0A41SK0F / GP2Y0AF30 series  use 430
10 to 80 cm GP2Y0A21YK0F  use 1080
10 to 150 cm GP2Y0A60SZLF use 10150
20 to 150 cm GP2Y0A02YK0F use 20150
100 to 550 cm GP2Y0A710K0F  use 100550

 */

SharpIR SharpIR(IR, model);
int dis;
int get_dist(){
    // Sharp IR code for Robojax.com  

  unsigned long startTime=millis();  // takes the time before the loop on the library begins

   dis=SharpIR.distance();  // this returns the distance to the object you're measuring

  // Sharp IR code for Robojax.com
//
//  Serial.print("Mean distance: ");  // returns it to the serial monitor
//  Serial.println(dis);
  //Serial.println(analogRead(A0));
  unsigned long endTime=millis()-startTime;  // the following gives you the time taken to get the measurement
// Serial.print("Time taken (ms): ");
// Serial.println(endTime);  
     // Sharp IR code for Robojax.com
     return dis;
     
}
