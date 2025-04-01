#CARD
#TITLE Timing your game loop in Windows

#HR 

If your making a game in Windows, your're going to want to time your game loop to find out how much time has elapsed since your last frame. If you've done game programming before you'll know you use it a lot - from animation to physics and AI. To find the time elapsed since last frame known as delta time or dt, we can use some Windows funcitons, specifically <i>QueryPerformanceCounter</i> and <i>QueryPerformanceFrequency</i>. 

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

By doing everything relative to the start performance count, we help improve the possible precision of the time when it's converted into a double value. 

We now have the delta time for our frame.  

#HR

###Conclusion

Hope you enjoyed this article. Happy game making!

#ANCHOR https://github.com/Olster1/windows_tutorials/blob/main/getExePath_function/main.cpp The full code can be found here

Thanks for reading!