#CARD
#TITLE Direct3d 11 for games: Part 6
##Timing your Game Loop
#CARD

This lesson is less about Direct3D and more about timing your game loop.

Once crucial thing of a game is how long has elapsed since your last frame has been shown to the user. By knowing this, you know how much to update your game by. To find the time elapsed since last frame known as <b>delta time</b> or <b>dt</b>, we can use some Windows funcitons, specifically <i>QueryPerformanceCounter</i> and <i>QueryPerformanceFrequency</i>. 

#HR

Before we enter the game loop we set up a few variables.

#CODE

// Timing
  LONGLONG startPerfCount = 0;
  LONGLONG perfCounterFrequency = 0;
  {
      //NOTE: Get the current performance counter at this moment to act as our reference
      LARGE_INTEGER perfCount;
      QueryPerformanceCounter(&perfCount);
      startPerfCount = perfCount.QuadPart;

      //NOTE: Get the Frequency of the performance counter to be able to convert from counts to seconds
      LARGE_INTEGER perfFreq;
      QueryPerformanceFrequency(&perfFreq);
      perfCounterFrequency = perfFreq.QuadPart;
      
  }

  //NOTE: To store the last time in
  double currentTimeInSeconds = 0.0;

  #ENDCODE

#HR 

Next in the game loop we want to calculate delta time for the frame. To do this we take the current performance count again, and find what it is relative to the start counter, then convert it to seconds. This will now be the time since we started our game loop. Now we can then find the difference between the time now and the time from the last frame.

#CODE
//NOTE: Inside game loop
float dt;
{
    double previousTimeInSeconds = currentTimeInSeconds;
    LARGE_INTEGER perfCount;
    QueryPerformanceCounter(&perfCount);

    currentTimeInSeconds = (double)(perfCount.QuadPart - startPerfCount) / (double)perfCounterFrequency;
    dt = (float)(currentTimeInSeconds - previousTimeInSeconds);
}

#ENDCODE

By doing everything relative to the start performance count instead of counts since time of computer boot, we help improve the possible precision of the time when it's converted into a double value. 

We now have the delta time for our frame which we can print out to see if V-Sync is working. If you have a 60fps monitor you should see a time around 16.66 (not exact since your the OS can decide when to call your program's thread). 

#CODE 
char buffer[256];
sprintf(buffer, "%f\n", dt);
OutputDebugStringA(buffer);
#ENDCODE

Hopefully you'll see how long your frame takes to render and if your swap interval is 1, you'll see the frame time matches your monitor refresh rate.

#ANCHOR https://github.com/Olster1/directX11_tutorial/tree/main/lesson6 You can see the full code for this article here

#HR

#Email

#HR

#INTERNAL_ANCHOR_IMPORTANT ./direct3d_11_part6.html PREVIOUS LESSON
#INTERNAL_ANCHOR_IMPORTANT ./direct3d_11_part7.html NEXT LESSON
