#CARD
#TITLE Direct3d 11 for games: Part 6
##Timing your Game Loop and Animating the Quad
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

We now have the delta time for our frame which we can print out. If you have a 60fps monitor you should see a time around 0.0166 if vy-sync is on (the first argument in swapBuffer being 1). However it won't be exact. The reasons behind this can be quite complex: you can read more behind the intricacies of frame timing and getting smooth gameplay in the notes [1].

#HR 

Here is the code we use to print out our dt value for each frame.

#CODE 
char buffer[256];
sprintf(buffer, "%f\n", dt);
OutputDebugStringA(buffer);
#ENDCODE

#HR

Also have to include <b>stdio.h</b> to use sprintf.

#CODE
//NOTE: At top of file
#include <stdio.h>
#ENDCODE	

#HR 

##Using the dt value in our code

Now that we have dt available to us we can use it to animate the position of our Quad.

We can use <b>dt</b> to update the position of the quad by changing the constant buffer position. 

#CODE 

//NOTE: Store time since start of game
static float totalTime = 0;
totalTime += dt; 

//...get pointer to constant buffer using Map from previous lesson
constants->pos = {cosf(totalTime)*0.25f, sinf(totalTime)*0.3f};

#ENDCODE

This code will make our quad move in a circle. 

Also have to #include  the Math.h header to use <i>cosf</i> and <i>sinf</i>.

#HR

##Conclusion

We did it, we're now timing our frame so we can update our game correctly.

#ANCHOR https://github.com/Olster1/directX11_tutorial/tree/main/lesson6 You can see the full code for this article here

#HR

##NOTES

[1] More articles on the intricacy's of frame timing 
<a href='https://gafferongames.com/post/fix_your_timestep/'>Fix Your Timestep</a>
<a href='https://medium.com/@alen.ladavac/the-elusive-frame-timing-168f899aec92'>The Elusive Frame Timing</a>
<a href='https://www.gdcvault.com/play/1025031/Advanced-Graphics-Techniques-Tutorial-The'>The Elusive Frame Timing: A Case Study for Smoothness Over Speed</a>video): 
<a href='https://www.gdcvault.com/play/1025407/Advanced-Graphics-Techniques-Tutorial-The'>The Elusive Frame Timing: A Case Study for Smoothness Over Speed</a>PDF): 
<a href='https://www.youtube.com/watch?v=_zpS1p0_L_o'>Myths and Misconceptions of Frame Pacing</a>
<a href='https://blogs.unity3d.com/2020/10/01/fixing-time-deltatime-in-unity-2020-2-for-smoother-gameplay-what-did-it-take/'>Fixing Time.deltaTime in Unity 2020.2 for smoother gameplay</a>
<a href='https://developer.android.com/games/sdk/frame-pacing'>Android - Achieve proper frame pacing</a>
<a href='https://developer.nvidia.com/reflex'>Low Latency Mode in NVIDIA Reflex SDK</a>


#Email

#HR

#INTERNAL_ANCHOR_IMPORTANT ./direct3d_11_part6.html PREVIOUS LESSON
#INTERNAL_ANCHOR_IMPORTANT ./direct3d_11_part7.html NEXT LESSON

