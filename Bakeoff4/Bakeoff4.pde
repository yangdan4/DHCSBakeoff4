import java.util.ArrayList;
import java.util.Collections;
import ketai.sensors.*;

KetaiSensor sensor;

float cursorX, cursorY;
float light = 0; 
float proxSensorThreshold = 2; //you will need to change this per your device.

private class Target
{
  int target = 0;
  int action = 0;
}

int trialCount = 5; //this will be set higher for the bakeoff
int trialIndex = 0;
ArrayList<Target> targets = new ArrayList<Target>();

int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
//int countDownTimerWait = 0;
int moveThreshold = 20;
float lastTime = -1;
float lastX = -1;
float lastY = -1;
int chosen = -1;
int choice = -1;
float tapTime = -1;

void setup() {
  size(1000, 1000); //you can change this to be fullscreen
  frameRate(60);
  sensor = new KetaiSensor(this);
  sensor.start();
  orientation(LANDSCAPE);

  rectMode(CENTER);
  textFont(createFont("Arial", 40)); //sets the font to Arial size 20
  textAlign(CENTER);

  for (int i=0; i<trialCount; i++)  //don't change this!
  {
    Target t = new Target();
    t.target = ((int)random(1000))%4;
    t.action = ((int)random(1000))%2;
    targets.add(t);
    println("created target with " + t.target + "," + t.action);
  }

  Collections.shuffle(targets); // randomize the order of the button;
}

void draw() {
  int index = trialIndex;
  //uncomment line below to see if sensors are updating
  //println("light val: " + light +", cursor accel vals: " + cursorX +"/" + cursorY);
  background(80); //background is light grey
  noStroke(); //no stroke

  //countDownTimerWait--;

  if (startTime == 0)
    startTime = millis();

  if (index>=targets.size() && !userDone)
  {
    userDone=true;
    finishTime = millis();
  }

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, 50);
    text("User took " + nfc((finishTime-startTime)/1000f/trialCount, 1) + " sec per target", width/2, 150);
    return;
  }
  if(chosen == -1)
  {
    for (int i=0; i<4; i++)
    {
      if (targets.get(index).target==i)
        fill(0, 255, 0);
      else
        fill(180, 180, 180);
      rectMode(CENTER);
      if(i == 0)
      {
        rect(350 + 150, 500 - 150, 100, 100);
        
      }
      else if(i == 1)
      {
        rect(350 + 150, 200 - 150, 100, 100);
        
      }
      else if(i == 2)
      {
        rect(500 + 150, 350 - 150, 100, 100);
        
      }
      else if(i == 3)
      {
        rect(200 + 150, 350 - 150, 100, 100);
      }
      //rect(200, 200, 100, 100);
    }
  }
  else
  {
    /*for (int i=0; i<2; i++)
    {
      if (targets.get(index).action == i)
        fill(0, 255, 0);
      else
        fill(180, 180, 180);
      rect((i % 2) * 300 + 300, (i / 2) * 300 + 300, 300, 300);
    }*/
  textSize(50);
  if (targets.get(index).action==0)
    text("SHAKE LEFT AND RIGHT", width/2, 150);
  else
    text("JERK UP OR DOWN", width/2, 150);
  }

  fill(255);//white
  text("Trial " + (index+1) + " of " +trialCount, width/2, 50);
  text("Target #" + (targets.get(index).target)+1, width/2, 100);
}

void onLinearAccelerationEvent(float x, float y, float z)
{
  int thres1 = 3;
  float cali = 0;
  if(chosen == 0)
  {
    if(abs(y - cali) > thres1 || abs(x - cali) > thres1)
    {
      if(abs(y - cali) > thres1 && targets.get(trialIndex).action == 0)
      {
        println("right action");
        if(choice == targets.get(trialIndex).target)
        {
          println("Right target");
          trialIndex++; //next trial
        } else
        {
          if (trialIndex>0)
          {
            trialIndex--; //move back one trial as penalty!
          }
          println("wrong target");
        }
      }
      else if(abs(x - cali) > thres1 && targets.get(trialIndex).action == 1)
      {  
        println("right action");
        if(choice == targets.get(trialIndex).target)
        {
          println("Right target");
          trialIndex++; //next trial
        } else
        {
          if (trialIndex>0)
          {
            trialIndex--; //move back one trial as penalty!
          }
          println("wrong target");
        }
      }
      else
      {
        if (trialIndex>0)
        {
           trialIndex--; //move back one trial as penalty!
        }
        println("Wrong action");
      }
      chosen = -1;
    }
  }
}

void onGyroscopeEvent(float x, float y, float z)
{
  
  
  
  int thres = 2;
  if(chosen == -1)
  {
    int index = trialIndex;
  
    if (userDone || index>=targets.size())
      return;
  
    Target t = targets.get(index);
  
    if (t==null)
      return;
    if(abs(x) > thres && abs(y) < thres)
    {
      if(x > thres)
      {
        //bottom
        choice = 2;
      }
      else if(x < -thres)
      {
        //top
        choice = 3;
      }
      chosen = 0;
    }
    else if(abs(x) < thres && abs(y) > thres)
    {
      if(y > thres)
      {
        //right
        choice = 1;
      }
      else if(y < -thres)
      {
        //left
        choice = 0;
      }
      chosen = 0;
    }
  }
  
  
  //println(x);
  /*if(lastTime < 0)
  {
    lastTime = millis();
    lastX = x;
    lastY = y;
  }
  else if(millis() - lastTime > 200)
  {
    lastTime = millis();
    float deltaX = x - lastX;
    float deltaY = y - lastY;
    println(x);
    if(abs(deltaX) > moveThreshold && abs(deltaY) < moveThreshold)
    {
      if(deltaX > moveThreshold)
      {
        println("right");
      }
      else if(deltaX < -moveThreshold)
      {
        println("left");
      }
    }
    else if(abs(deltaY) > moveThreshold && abs(deltaX) < moveThreshold)
    {
      if(deltaY > moveThreshold)
      {
        println("forward");
      }
      else if(deltaY < -moveThreshold)
      {
        println("backward");
      }
    }
  }*///end comment here
  
  
}

/*void onLightEvent(float v) //this just updates the light value
{
  if(chosen == 0)
  {
    if(v < proxSensorThreshold)
    {
      if(targets.get(trialIndex).action == 1)
      {
        println("right action");
        if(choice == targets.get(trialIndex).target)
        {
          println("Right target");
          trialIndex++; //next trial
        } else
        {
          if (trialIndex>0)
          {
            trialIndex--; //move back one trial as penalty!
          }
          println("wrong target");
        }
      }
      else
      {
        if (trialIndex>0)
        {
           trialIndex--; //move back one trial as penalty!
        }
        println("Wrong action");
      }
      chosen = -1;
    }
  }
}*/