#CARD
#TITLE Direct3d 11 for games: Part 1
##Creating a window
#HR
#CARD
#ANCHOR_IMPORTANT https://github.com/kevinmoran/BeginnerDirect3D11 This series is based on Kevin Moran's brilliant Direct3D tutorial code which you can get here

In this article, I’m going to walk through creating a Direct3D 11 context to use with your games. Direct3D 11 is the native graphics API for Windows. Direct3D has advantages over OpenGL in that it is more reliable on Windows computers — this is an advantage when it comes time to ship your game. You want it to work on as many machines as possible with the least hiccups. You don’t want half your users (or worse!) to load your game up and find a blank screen. The other advantage over OpenGL is that Direct3D is a lot easier to reason about. OpenGL is a giant state machine where you bind textures, vertex arrays, and options like blend modes which stay bound until you specifically unbind them or unset them. This can lead to bugs that can be hard to find. Direct3D 11 API is less of a state machine, and more function calls that you can reason, making the experience of graphics program more enjoyable.

#HR

##Contents

####<a href='#id0'>Entry Point to a Windows program</a> 
####<a href='#id1'>Creating a Window Class</a> 
####<a href='#id2'>Windows Message Callback function</a>
####<a href='#id3'>Creating our window</a>
####<a href='#id4'>The Game Loop</a>
####<a href='#id5'>Handling the Operating Systems messages</a>
####<a href='#id6'>Quiz</a>

#HR

###<span id='id0'>Our Entry Point</span>

Let's get started! The first thing for any Windows program is the windows entry point which we’re going to stick into a C++ file. Let's call it main.cpp. It looks like this:

#CODE
#include <windows.h>
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE /*hPrevInstance*/, LPSTR /*lpCmdLine*/, int /*nShowCmd*/) {
return 0;
}
#ENDCODE

We’ve commented out the variables we don’t use in our program — we only use the first variable of the function, the hInstance — this is the instance of our exe running, which we’re going to need to create a window.
We can compile this to make sure everything is working. We’re using the MSVC compiler from the command line so we’re going to type:

#CODE
cl main.cpp
#ENDCODE

Great! Hopefully, there aren’t any compiler errors. 

##<span id='id1'>Creating a Window class</span>

Next, we’re going to declare a window class. This is something you create before actually creating the window to choose the settings for the window. Things like which process this window will belong to, the Icon and cursor symbols. Nothing very special. It looks something like this:

#CODE
//First register the type of window we are going to create
WNDCLASSEXW winClass = {};
winClass.cbSize = sizeof(WNDCLASSEXW);
winClass.style = 0;
winClass.lpfnWndProc = &WndProc;
winClass.hInstance = hInstance;
winClass.hIcon = LoadIconW(0, IDI_APPLICATION);
winClass.hCursor = LoadCursorW(0, IDC_ARROW);
winClass.lpszClassName = L"MyWindowClass";
winClass.hIconSm = LoadIconW(0, IDI_APPLICATION);
if(!RegisterClassExW(&winClass)) {
    MessageBoxA(0, "RegisterClassEx failed", "Fatal Error", MB_OK);
    return GetLastError();
}
#ENDCODE

We declare a struct call winClass of type WINDCLASSEXW. Notice we’re using the W versions of the WinAPI functions. There is also the A type. The difference is that the W type support Unicode strings (W meaning wide characters or 2 bytes per character), whereas the A type only support ANSI characters (non unicode, with only 1 byte per character). So to be more up to date we’re using the W functions. There are two other things we’ll add to support unicode:

1. Put the define unicode at the top of our file (above #include windows.h). This tells other windows functions we’re supporting unicode so please help us.

#CODE
#define UNICODE
#include <windows.h>
#ENDCODE

2. Put L before a string literal. This tells the compiler to treat the string as a wide string (2 bytes per character). This looks like this L”MyWindowClass”.

#ANCHOR http://www.cplusplus.com/forum/articles/16820/ You can read more about Unicode support on windows here

For the style you might see <i>CS_HREDRAW | CS_VREDRAW</i> be used in other code you come across. This is to say redraw the window when the window is resized (H for horizontal, V for Vertical). This is only neccessary if you're not re-drawing the window yourself. Since we are using direct3D and redrawing the contents of our window each frame, we don't have to worry about this.

You'll see we also create a MessageBox which (a Windows popup box) if the function fails and exit the program. 

#HR

##<span id="id2">Windows Message Callback function</span>

The main thing to notice about the Window Class is we’re passing a pointer to a function called WndProc seen in the line <i>winClass.lpfnWndProc = &WndProc;</i>

<img src='./photos/directX_lesson1_pictures/directx03.png' style='width: 60%;'>

This is the callback that handles events sent to our app like resizing, keyboard input, and exiting our program. We have to define it ourselves, so we’ll do that above our main function. It looks like this:

#CODE
LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
    LRESULT result = 0;
    switch(msg) {
        case WM_CLOSE:
        case WM_DESTROY : {
            PostQuitMessage(0);
        } break;
        default:
            result = DefWindowProcW(hwnd, msg, wparam, lparam);
    }
    return result;
}
#ENDCODE

You’ll see that we’re handling the WM_CLOSE and WM_DESTROY messages sent when the user closes the window. We post a QuitMessage which we’ll handle in our message loop telling the program to exit. All other events we give to the default function for now. Here you'd handle keyboard and mouse input. <a href="./windows-keyboard-input.html">This article goes into more depth of doing this.</a> 

#HR

##<span id="id3">Creating our window</span>

Next we’ll actually create our window.
<img src='./photos/directX_lesson1_pictures/directx01.png' style='width: 50vw;'>
#CODE
//Now create the actual window

LONG initialWidth = 960;
LONG initialHeight = 540;

HWND hwnd = CreateWindowExW(WS_EX_OVERLAPPEDWINDOW,
                                winClass.lpszClassName,
                                L"Awesome Program Name!",
                                WS_OVERLAPPEDWINDOW | WS_VISIBLE,
                                CW_USEDEFAULT, CW_USEDEFAULT,
                                initialWidth, 
                                initialHeight,
                                0, 0, hInstance, 0);
if(!hwnd) {
            MessageBoxA(0, "CreateWindowEx failed", "Fatal Error", MB_OK);
            return GetLastError();
        }
#ENDCODE
We use the CreateWindowExW to actually create our window. We give it the windowclass we created before and give the window a name - in this case "My Window". We also are passing our hInstance (the handle to our exe) and some initial flags — WS_OVERLAPPEDWINDOW | WS_VISIBLE (we want a normal window type and we want our window to be visible). 

We also pass the initial size of our window. There is something to note here — the initial width & height of the window include the border, to get the actually inner dimension to be what we want we have to do this:

#CODE
RECT initialRect = { 0, 0, 960, 540 };
AdjustWindowRectEx(&initialRect, WS_OVERLAPPEDWINDOW, FALSE, WS_EX_OVERLAPPEDWINDOW);
LONG initialWidth = initialRect.right - initialRect.left;
LONG initialHeight = initialRect.bottom - initialRect.top;

#ENDCODE

We pass in the dimensions we want for our inner window, and it gives back the dimensions including the border that we should pass to CreateWindow.
<img src='./photos/directX_lesson1_pictures/directx02.png' style='width: 50vw;'>

So our full code for creating the window ends up looking like this.

#CODE
//NOTE: We want the window to be 960px wide by 540px high
RECT initialRect = { 0, 0, 960, 540 };
AdjustWindowRectEx(&initialRect, WS_OVERLAPPEDWINDOW, FALSE, WS_EX_OVERLAPPEDWINDOW);
LONG initialWidth = initialRect.right - initialRect.left;
LONG initialHeight = initialRect.bottom - initialRect.top;


HWND hwnd = CreateWindowExW(WS_EX_OVERLAPPEDWINDOW,
                                winClass.lpszClassName,
                                L"Awesome Program Name!",
                                WS_OVERLAPPEDWINDOW | WS_VISIBLE,
                                CW_USEDEFAULT, CW_USEDEFAULT,
                                initialWidth, 
                                initialHeight,
                                0, 0, hInstance, 0);
if(!hwnd) {
            MessageBoxA(0, "CreateWindowEx failed", "Fatal Error", MB_OK);
            return GetLastError();
        }

#ENDCODE

We again display a message box to the user if we can't create the window and exit our program. 

Great! If we compile this now we should see a window briefly appear then disappear again. Let’s do that.

<span id="compiler-bat">To compile is now we need to pass a linker flag since we’re using functions that live in <i>user32.lib</i></span>

#CODE
cl main.cpp /link user32.lib
#ENDCODE
Now when we run this and run our main.exe, we should see our window briefly appear. To finish this lesson of we’re going to add the infamous game loop.
#HR
###<span id='id4'>The Game Loop</span>
<img src='./photos/directX_lesson1_pictures/directx04.png' style='width: 50vw;'>

Below our CreateWindow function, we’ll write this:
#CODE
bool running = true;
while(running) {

//NOTE: Our per frame game code here

}

#ENDCODE

This is the game loop in which we put all our game-logic that get's updated each frame. To actually make this usable we have to add one more thing.

#HR

##<span id='id5'>Handling the Operating Systems messages</span>

If we ran this, we’d be stuck in an infinite loop since we don’t handle our messages — specifically our exit message. Each time the OS sends our pogram a message, it gets added to a queue. This don't get processed by themselves, we ourselves have to empty this queue. The function <i>Peek Message</i> is used to retrieve the message from the bottom of the queue. To process all the messages on the queue, we stay in a while loop until PeekMessage returns false, signifying there aren't any messages left. 

For each message we first check if it's a WM_QUIT message, if so we want to exit our game loop. We then use <i>Translate Message</i> to turn any Keyboard Input that is text into WM_CHAR messages. We then call <i>DispatchMessage</i>. All the work of dealing with the messages is done in this function, as it calls our message callback.

We could also use <i>GetMessage</i> to receive our messages. The difference is that <i>GetMessage</i> stays waiting for messages to process, instead of continuing on with the program. If you wanted to make a text editor or slideshow where the program didn't need to update the frames between input you'd want to use <i>GetMessage</i> to save CPU usage. For a game you want <i>PeekMessage</i> since it is animating in real time.

#CODE
bool running = true;
while(running) {
    
        //NOTE: Our message loop we run each frame, going through each message in the queue
        MSG msg = {};
        while(PeekMessageW(&msg, 0, 0, 0, PM_REMOVE))
        {   
            //NOTE: Set running to false if got a WM_QUIT message
            if(msg.message == WM_QUIT) {
                running = false;
            }
            TranslateMessage(&msg);

            //NOTE: Send our message to our callback (WndProc)
            DispatchMessageW(&msg);
        }
}
#ENDCODE


Now if we compile it using the same code as above <a href='#compiler-bat'>(cl main.cpp /link user32.lib)</a> and run it, we’ll get a window that stays open. We can quit it by pressing the Red X.

Awesome! Well done. We’re on our way to getting a direct3d renderer going.

The full code up to this point should look like this: 

#CODE
#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#define UNICODE
#include <windows.h>
    
//NOTE: Our Message Callback 
LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam)
{
    LRESULT result = 0;
    switch(msg) {
        //NOTE: Handle when the user quits the window
        case WM_DESTROY:
        case WM_CLOSE: {
            PostQuitMessage(0);
        } break;
        default:
            result = DefWindowProcW(hwnd, msg, wparam, lparam);
    }
    return result;
}

//NOTE: Entry point of our program 
int APIENTRY WinMain(HINSTANCE hInstance, HINSTANCE hInstPrev, PSTR cmdline, int cmdshow)
{
    // Open a window
    HWND hwnd;
    {   
        //NOTE: First register the type of window we are going to create
        WNDCLASSEXW winClass = {};
        winClass.cbSize = sizeof(WNDCLASSEXW);
        winClass.style = 0;
        winClass.lpfnWndProc = &WndProc;
        winClass.hInstance = hInstance;
        winClass.hIcon = LoadIconW(0, IDI_APPLICATION);
        winClass.hCursor = LoadCursorW(0, IDC_ARROW);
        winClass.lpszClassName = L"MyWindowClass";
        winClass.hIconSm = LoadIconW(0, IDI_APPLICATION);

        //NOTE: Register the window class and display Error if we can't
        if(!RegisterClassExW(&winClass)) {
            MessageBoxA(0, "RegisterClassEx failed", "Fatal Error", MB_OK);
            return GetLastError();
        }

        //Now create the actual window

        //NOTE: First get the dimensions for the window based on our desired innner window dimension
        RECT initialRect = { 0, 0, 960, 540 };
        AdjustWindowRectEx(&initialRect, WS_OVERLAPPEDWINDOW, FALSE, WS_EX_OVERLAPPEDWINDOW);
        LONG initialWidth = initialRect.right - initialRect.left;
        LONG initialHeight = initialRect.bottom - initialRect.top;


        //NOTE: Create the Window
        hwnd = CreateWindowExW(WS_EX_OVERLAPPEDWINDOW,
                                winClass.lpszClassName,
                                L"Awesome Program Name!",
                                WS_OVERLAPPEDWINDOW | WS_VISIBLE,
                                CW_USEDEFAULT, CW_USEDEFAULT,
                                initialWidth, 
                                initialHeight,
                                0, 0, hInstance, 0);

        //NOTE: If we couldn't make the window display an error and exit
        if(!hwnd) {
            MessageBoxA(0, "CreateWindowEx failed", "Fatal Error", MB_OK);
            return GetLastError();
        }
    }

    //NOTE: Our Per Frame Game Loop
    bool running = true;
    while(running) {
        //NOTE: Process our message queue
        MSG msg = {};
        while(PeekMessageW(&msg, 0, 0, 0, PM_REMOVE))
        {
            //NOTE: Exit our game loop if we see a WM_QUIT message
            if(msg.message == WM_QUIT)
                running = false;

            TranslateMessage(&msg);

            //NOTE: Deliver our message to our message callback
            DispatchMessageW(&msg);
        }
    }
    

    return 0;

}

#ENDCODE


#ANCHOR_IMPORTANT https://github.com/Olster1/directX11_tutorial/blob/main/lesson1/main.cpp You can see all the code for this lesson on Github here

#HR

#Email

#HR

##<span id='id6'>QUIZ</span>

<b>What function to we use to create a Window?</b>
[CreateWindowExW]

<b>What do we need to pass to CreateWindow?</b>
[A windowClass which we register before creating a window. It also contains the function pointer to out event callback wndProc for handling input]
<b>What do we do at the start of every game loop?</b>
[We process the messages that have come in using PeekMessage. And Dispatch them to our Message Callback we set in our WindowClass]
<b>When is our WndProc function called?</b>
[When we use DispatchMessage()]

#HR

##Next Lesson

In the next lesson we'll actually start using Direct3D to clear the screen to a color. 

#INTERNAL_ANCHOR_IMPORTANT ./direct3d_11_part2.html Go to Part 2 of the Direct3D lessons


