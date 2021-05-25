#CARD
#TITLE Windows Keyboard input
#CARD

Getting input from the player is the crucial for a game; without it it's not a game, it's a movie. So how do we get input from the user and what's the best way to keep track of it? 

In this article we're going to walk through getting input from the user's keyboard on Windows. We'll also go through how to store it and use it in our game. Let's Go!

#HR

##Contents

####<a href='#id0'>Message Callback</a> 
####<a href='#id1'>WM_KEYDOWN and WM_KEYUP messages</a> 
####<a href='#id2'>Virtual Key Codes</a>
####<a href='#id3'>Making an enum value for each key</a>
####<a href='#id4'>Adding KeyPressed and KeyReleased</a>
####<a href='#id5'>Multiple Key Presses and Releases Per Frame</a>
####<a href='#id6'>Handling WM_SYSKEYDOWN and WM_SYSKEYUP</a>
####<a href='#id7'>Using lparam instead of previous <i>isDown</i> value</a>
####<a href='#id8'>Mouse Input</a>
####<a href='#id9'>Get Cursor Coordinates</a>
####<a href='#id10'>Platform Input Struct</a>


#HR

##<span id='id0'>Message Callback</span>

The core of our input is in the WndProc message callback. This is the way the OS sends our program messages like if the user clicks the red cross button, resizes the window or presses buttons. It looks like this: 

#CODE 

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
    LRESULT result = 0;

    result = DefWindowProcW(hwnd, msg, wparam, lparam);

    return result;
} 

#ENDCODE 

#ANCHOR https://docs.microsoft.com/en-us/windows/win32/learnwin32/writing-the-window-procedure You can read more about this function here.  

When we create our window class we give it this function to send all messages through. Then when we process our messages in our game loop using <i>Peek Message</i>, our function will be called when we call <i>DispatchMessage</i>. <a href="./create_direct_x_11.html">This tutorial walks you through doing this.</a> 

#ANCHOR https://github.com/Olster1/directX11_tutorial/blob/main/lesson1/main.cpp You can see what our basic program would look like using handling OS messages. 

##<span id='id1'>WM_KEYDOWN and WM_KEYUP messages</span>

We don't do anything yet with the messages we recieve, we just pass them to the default handler. We going to want to change that! 

#CODE
LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
    LRESULT result = 0;

    if(msg == WM_KEYDOWN || msg == WM_KEYUP) {
    	//NOTE: handle our keyboard input
    } else {
    	result = DefWindowProcW(hwnd, msg, wparam, lparam);
    }

    return result;
} 
#ENDCODE

We're also going to handle messages sent when the user closes the app. 

#CODE
LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
    LRESULT result = 0;

    if(msg == WM_CLOSE || msg == WM_DESTROY) {
    	//NOTE: We handle this message in our game loop
    	PostQuitMessage(0);
    } else if(msg == WM_KEYDOWN || msg == WM_KEYUP) {
    	//NOTE: handle our keyboard input
    } else {
    	result = DefWindowProcW(hwnd, msg, wparam, lparam);
    }

    return result;
} 
#ENDCODE

Using the message type, we can see what messages the OS has sent us. The two messages we want to handle is the WM_KEYDOWN and WM_KEYUP; these are messages for when the user presses, holds and releases a button. Using just these messages the user could control a character.  

#HR 
##<span id='id2'>Virtual Key Codes</span>

We now know when a user presses a key, next we need to know which key it was. This is called the <i>Virtual key code</i>. It's virtual because depending on the mapping of the user's keyboard it might not be the actual key they pressed, but the mapped value. The Virtual key code or VK code is the <i>wparam</i> value passed into the function. 

#ANCHOR https://docs.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes You can see all the VK codes corresponding to the keys here

Let's start with the Up, Down, Left and Right arrows.

#CODE
LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
    LRESULT result = 0;

    if(msg == WM_KEYDOWN || msg == WM_KEYUP) {
    	
    	//NOTE: handle our keyboard input
    	if(wparam == VK_UP) {

    	} else if(wparam == VK_DOWN) {

    	} else if(wparam == VK_LEFT) {

    	} else if(wparam == VK_RIGHT) {

    	}

    } else {
    	result = DefWindowProcW(hwnd, msg, wparam, lparam);
    }

    return result;
} 
#ENDCODE


Whenever the user presses, holds or releases an Arrow key we'll get a message here. Let's store this so the game logic can use it. Since the message callback function is isolated from our main function and we can't pass any custom parameters into it, we have to use a <b>global variable</b> store them. It would look like this:

#CODE

static bool global_keyDownStates[4];   

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
    LRESULT result = 0;

    //NOTE: Handle our messages 
    // ...  

    return result;
}

#ENDCODE

We're using a bool to say whether the key is down or not, and each key mapped to an index in the array. 
In our callback we will set the values of this array. 

#CODE
static bool global_keyDownStates[4];  

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
    LRESULT result = 0;

    if(msg == WM_KEYDOWN || msg == WM_KEYUP) {

    	bool keyDown = (msg == WM_KEYDOWN);
    	
    	//NOTE: handle our keyboard input
    	if(wparam == VK_UP) {        
            global_keyDownStates[0] = keyDown;

    	} else if(wparam == VK_DOWN) {
            global_keyDownStates[1] = keyDown;

    	} else if(wparam == VK_LEFT) {
           global_keyDownStates[2] = keyDown;

    	} else if(wparam == VK_RIGHT) {
          global_keyDownStates[3] = keyDown;
    	}

    } else {
    	result = DefWindowProcW(hwnd, msg, wparam, lparam);
    }

    return result;
} 
#ENDCODE

When the user press the up arrow key a WM_KEYUP message will be sent. We then set the array value to true. It will stay true until the user releases the key, in that case a WM_KEYUP message will be sent and the value will be set to false. Awesome!

In our game loop we could use this now to control a character:

#CODE
		
	bool running = true;
	while(running) {

		MSG message;
		while(PeekMessage(&message, 0, 0, 0, PM_REMOVE))
		{	
			if(message.message == WM_QUIT) {
				//NOTE: Exit our game loop
				running = false;
			}

		    TranslateMessage(&message);
		    DispatchMessage(&message); //NOTE: our message callback is handled here
		}

		//NOTE: Use our global array to access the key down states 
		if(global_keyDownStates[0]) {
			//NOTE: Move Character forward
		}

		if(global_keyDownStates[2]) {
			//NOTE: Move Character left
		}

		if(global_keyDownStates[3]) {
			//NOTE: Move Character right
		}
	}

#ENDCODE  

#HR

##<span id='id3'>Making an enum value for each key</span>

To make it easier to read and for us to less likely make a mistake, instead of using the array index directly, we'll make a enum value for each key we want to use:

#CODE
	
	enum PlatformKeyType {
		PLATFORM_KEY_UP,
		PLATFORM_KEY_DOWN,
		PLATFORM_KEY_LEFT,
		PLATFORM_KEY_RIGHT
	};
#ENDCODE 

Then in our message loop we can use these instead of array indexes.

#CODE
static bool global_keyDownStates[4];  

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
    LRESULT result = 0;

    if(msg == WM_KEYDOWN || msg == WM_KEYUP) {

    	bool keyDown = (msg == WM_KEYDOWN);

    	//NOTE: handle our keyboard input
    	if(wparam == VK_UP) {        
            global_keyDownStates[PLATFORM_KEY_UP] = keyDown;

    	} else if(wparam == VK_DOWN) {
            global_keyDownStates[PLATFORM_KEY_DOWN] = keyDown;

    	} else if(wparam == VK_LEFT) {
           global_keyDownStates[PLATFORM_KEY_LEFT] = keyDown;

    	} else if(wparam == VK_RIGHT) {
          global_keyDownStates[PLATFORM_KEY_RIGHT] = keyDown;
    	}

    } else {
    	result = DefWindowProcW(hwnd, msg, wparam, lparam);
    }

    return result;
} 
#ENDCODE

Great! If all our game wanted was whether the key was up or down, say a racing game, this would be it. We would just handle more of the keys we wanted in our callback. So we don't have to expand the global array each time we add a new key, we will make it based of the size of the number of enums. 

#CODE

	enum PlatformKeyType {
		PLATFORM_KEY_UP,
		PLATFORM_KEY_DOWN,
		PLATFORM_KEY_LEFT,
		PLATFORM_KEY_RIGHT,

		//NOTE: Everthing before here
		PLATFORM_KEY_TOTAL_COUNT
	};

	static bool global_keyDownStates[PLATFORM_KEY_TOTAL_COUNT];  

#ENDCODE 

#ANCHOR https://github.com/Olster1/windows_tutorials/tree/main/windows_keyboard_input/01%20version%20-%20just%20down%20or%20up You can see the code up to this point.

#HR

##<span id='id4'>Adding KeyPressed and KeyReleased</span>

If we're not making a racing game, we're going to need the ability to see when the key was also pressed (true just on the frame the key is pressed) and released (true just on the frame when the user releases the key).

To keep track of these two extra values, we'll store a struct per key in the array instead of just the bool.

#CODE

struct PlatformKeyState {
	bool isDown;
	bool wasPressed;
	bool wasReleased;
};

static PlatformKeyState global_keyDownStates[PLATFORM_KEY_TOTAL_COUNT];  

#ENDCODE

In our message loop we now have to set these values:

#CODE
//NOTE: We've added the z and x key, also a null type
enum PlatformKeyType {
	PLATFORM_KEY_NULL,
	PLATFORM_KEY_UP,
	PLATFORM_KEY_DOWN,
	PLATFORM_KEY_LEFT,
	PLATFORM_KEY_RIGHT,
	PLATFORM_KEY_Z,
	PLATFORM_KEY_X,

	//NOTE: Everthing before here
	PLATFORM_KEY_TOTAL_COUNT
};

static PlatformKeyState global_keyDownStates[PLATFORM_KEY_TOTAL_COUNT];  

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
    LRESULT result = 0;

    if(msg == WM_KEYDOWN || msg == WM_KEYUP) {

    	bool keyDown = (msg == WM_KEYDOWN);
	
		WPARAM vk_code = wparam;    	

		PlatformKeyType keyType = PLATFORM_KEY_NULL; 

    	//NOTE: match our internal key names to the vk code
    	if(vk_code == VK_UP) { 
    		keyType = PLATFORM_KEY_UP;
    	} else if(vk_code == VK_DOWN) {
    		keyType = PLATFORM_KEY_DOWN;
    	} else if(vk_code == VK_LEFT) {
    		keyType = PLATFORM_KEY_LEFT;
    	} else if(vk_code == VK_RIGHT) {
    		keyType = PLATFORM_KEY_RIGHT;
    	} else if(vk_code == 'Z') {
    		keyType = PLATFORM_KEY_Z;
    	} else if(vk_code == 'X') {
    		keyType = PLATFORM_KEY_X;
    	}


    	//NOTE: Key pressed, key down and key release events  
    	if(keyType != PLATFORM_KEY_NULL) {
    	
    	//NOTE: We can use the last isDown state to see if it is a key press and key release

    	//NOTE: Key press
    	global_keyDownStates[keyType].wasPressed = (keyDown && 
    	!global_keyDownStates[keyType].isDown);

    	//NOTE: key release
    	global_keyDownStates[keyType].wasReleased = (!keyDown && 
    	global_keyDownStates[keyType].isDown);

    	//NOTE: set is down
    	global_keyDownStates[keyType].isDown = keyDown;

  	  	}

    } else {
    	result = DefWindowProcW(hwnd, msg, wparam, lparam);
    }

    return result;
} 

#ENDCODE 

We use the last down state of the button to see if the key was up or down previously to this message, to find whether the message is a key press or key release.

You'll see the letter VK codes are the uppercase character value of it. 

Now in the game code we can see whether a key was pressed and released, not just is down. This is handy for example, if you play as a wizard in your game and only want the player to cast a spell when they press the z key and not keep casting a spell while the key is down. 

#CODE 

//NOTE: The Game Loop
bool running = true;
while(running) {
	
	//NOTE: Clear the key pressed and released so we only ever have it once per frame
	for(int i = 0; i < PLATFORM_KEY_TOTAL_COUNT; ++i) {
		global_keyDownStates[i].wasPressed = false;
		global_keyDownStates[i].wasReleased = false;
	}

	MSG message;
	while(PeekMessage(&message, 0, 0, 0, PM_REMOVE))
	{
		if(message.message == WM_QUIT) {
			//NOTE: Exit our game loop
			running = false;
		}

	    TranslateMessage(&message);
	    DispatchMessage(&message); //NOTE: our message callback is handled here
	}

	//NOTE: Use our global array to access the key pressed state 
	if(global_keyDownStates[PLATFORM_KEY_Z].wasPressed) {
		castSpell();
	}
}

#ENDCODE

We're now succesfully handling pressed and released key events!

You'll see we also set the <i>wasPressed</i> and <i>wasReleased</i> state to false at the <b>start of each frame before we process the messages</b>. This is because we only ever want the <i>wasPressed</i> and <i>wasReleased</i> value valid for one frame; if we don't clear the array and rely on a second WM_KEYDOWN message to set the values to false, the <i>wasPressed</i> value will be true for more than one frame (and a lot more) due to the repeat delay Windows and other Operating Systems use. The second message of a key being down won't come straight away but after a short interval.   

#HR

##<span id='id5'>Multiple Key Presses and Releases Per Frame</span>

You might have noticed a caveat with our method. Since we process all messages since the last message loop at once, a user might have pressed the key twice since last frame. That means we would get a WM_KEYDOWN message, then a WM_KEYUP message then another WM_KEYDOWN message. But when we process the messages for that frame, we wouldn't know this since only the last message is relfected in our keystate for that frame[1]: we would just know in the frame that the key was pressed and is down, not that is was pressed and released before that. 

If the game is running at 60fps or 30fps this might not be a problem since the user and the keyboard has to register more than one key event in less than 0.016seconds. However if it is an esport game using a keyboard with a high scan rate [2] or a frame lags behind by a signficant amount we would want to take this into consideration. Instead of storing a bool for <i>wasPressed</i> and <i>wasReleased</i>, we're going to store an integer. 

#CODE 

struct PlatformKeyState {
	bool isDown;
	int pressedCount;
	int releasedCount;
};

#ENDCODE

At the start of each frame we're going to clear the pressed and released count for the last frame so we know we're starting from a clean slate. Let's do that.

#CODE

//NOTE: The Game Loop
bool running = true;
while(running) {

	//NOTE: Clear the key pressed and released count before processing our messages
	for(int i = 0; i < PLATFORM_KEY_TOTAL_COUNT; ++i) {
		global_keyDownStates[i].pressedCount = 0;
		global_keyDownStates[i].releasedCount = 0;
	}

	MSG message;
	while(PeekMessage(&message, 0, 0, 0, PM_REMOVE))
	{	
		if(message.message == WM_QUIT) {
			//NOTE: Exit our game loop
			running = false;
		}

	    TranslateMessage(&message);
	    DispatchMessage(&message); //NOTE: our message callback is handled here
	}
}

#ENDCODE
 
Now in our message callback we'll increment the count when we get a key press and key release.

#CODE 

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
    LRESULT result = 0;

    if(msg == WM_KEYDOWN || msg == WM_KEYUP) {

    	bool keyDown = (msg == WM_KEYDOWN);
	
		WPARAM vk_code = wparam;    	

		PlatformKeyType keyType = PLATFORM_KEY_NULL; 

    	//NOTE: match our internal key names to the vk code
    	if(vk_code == VK_UP) { 
    		keyType = PLATFORM_KEY_UP;
    	} else if(vk_code == VK_DOWN) {
    		keyType = PLATFORM_KEY_DOWN;
    	} else if(vk_code == VK_LEFT) {
    		keyType = PLATFORM_KEY_LEFT;
    	} else if(vk_code == VK_RIGHT) {
    		keyType = PLATFORM_KEY_RIGHT;
    	} else if(vk_code == 'Z') {
    		keyType = PLATFORM_KEY_Z;
    	} else if(vk_code == 'X') {
    		keyType = PLATFORM_KEY_X;
    	}


    	//NOTE: Key pressed, is down and release events  
    	if(keyType != PLATFORM_KEY_NULL) {
    		int wasPressed = (keyDown && !global_keyDownStates[keyType].isDown) ? 1 : 0;
    		int wasReleased = (!keyDown && global_keyDownStates[keyType].isDown) ? 1 : 0;

    		global_keyDownStates[keyType].pressedCount += wasPressed;
    		global_keyDownStates[keyType].releasedCount += wasReleased;

    		global_keyDownStates[keyType].isDown = keyDown;
    	}

    } else {
    	result = DefWindowProcW(hwnd, msg, wparam, lparam);
    }

    return result;
} 

#ENDCODE 

Now in the game code we can use the number of key presses instead of just a boolean. 

#CODE
	//NOTE: The Game Loop
	bool running = true;
	while(running) {

		//NOTE: Clear the key pressed and released count before processing our messages
		for(int i = 0; i < PLATFORM_KEY_TOTAL_COUNT; ++i) {
			global_keyDownStates[i].pressedCount = 0;
			global_keyDownStates[i].releasedCount = 0;
		}

		MSG message;
		while(PeekMessage(&message, 0, 0, 0, PM_REMOVE))
		{	
			if(message.message == WM_QUIT) {
				//NOTE: Exit our game loop
				running = false;
			}

		    TranslateMessage(&message);
		    DispatchMessage(&message); //NOTE: our message callback is handled here
		}

		//NOTE: Cast the spell the number of times the user pressed the key in the last frame
		for(int i = 0; i < global_keyDownStates[PLATFORM_KEY_Z].pressedCount; ++i) {
			castSpell();
		}
	}

#ENDCODE

We're now successfully handling multiple key press and releases per frame. To finish off key input we'll cover two more quick house keeping things. 

#HR

##<span id='id6'>Handling WM_SYSKEYDOWN and WM_SYSKEYUP</span>

We are also going to handle two other message types: WM_SYSKEYUP and WM_SYSKEYDOWN. This is the same as WM_KEYDOWN and WM_KEYUP but sent instead when the user is holding the ALT key down aswell. Since we would do any key modifiers ourself in our program, we'll handle both types of messages in the same way, irrespective of whether the user is holding ALT down.

Let's put them in.

#CODE
LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
    LRESULT result = 0;

    if(msg == WM_SYSKEYDOWN || msg == WM_SYSKEYUP || 
    message == WM_KEYDOWN || message == WM_KEYUP) {
    	//NOTE: handle our keyboard input
    } else {
    	result = DefWindowProcW(hwnd, msg, wparam, lparam);
    }

    return result;
} 
#ENDCODE

#HR

##<span id='id7'>Using lparam instead of previous <i>isDown</i> value</span>  

The current way we detect key presses is to rely on the previous <i>isDown</i> value to see if the incoming WM_KEYDOWN message is a representing a key press or just a repeated key down. If we like we don't have to rely on our previous key down state, as the incoming message comes with this in the lparam value. Specifically the 30th bit in the value is 1 if the key was down before the message is sent, or it is zero if the key was up. And the 30th bit is whether the key is up (value of 1) or down (value of 0). This is just a different way of doing it and provides no extra benefits.

#ANCHOR https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-keydown You can read more about the message WM_KEYDOWN here and what the incoming parameters correspond to
#ANCHOR https://docs.microsoft.com/en-us/windows/win32/inputdev/wm-keyup Same but for WM_KEYUP

Our message callback would now look like this. 

#CODE
LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
    LRESULT result = 0;

    if(msg == WM_SYSKEYDOWN || msg == WM_SYSKEYUP || 
    message == WM_KEYDOWN || message == WM_KEYUP) {

    	bool keyWasDown = ((l_param & (1 << 30)) == 0);
    	bool keyIsDown =   !(l_param & (1 << 31));

		WPARAM vk_code = wparam;    	

		PlatformKeyType keyType = PLATFORM_KEY_NULL; 

    	//NOTE: match our internal key names to the vk code
    	if(vk_code == VK_UP) { 
    		keyType = PLATFORM_KEY_UP;
    	} else if(vk_code == VK_DOWN) {
    		keyType = PLATFORM_KEY_DOWN;
    	} else if(vk_code == VK_LEFT) {
    		keyType = PLATFORM_KEY_LEFT;
    	} else if(vk_code == VK_RIGHT) {
    		keyType = PLATFORM_KEY_RIGHT;
    	} else if(vk_code == 'Z') {
    		keyType = PLATFORM_KEY_Z;
    	} else if(vk_code == 'X') {
    		keyType = PLATFORM_KEY_X;
    	}


    	//NOTE: Key pressed, is down and release events  
    	if(keyType != PLATFORM_KEY_NULL) {
    		int wasPressed = (keyIsDown && !keyWasDown) ? 1 : 0;
    		int wasReleased = (!keyIsDown) ? 1 : 0;

    		global_keyDownStates[keyType].pressedCount += wasPressed;
    		global_keyDownStates[keyType].releasedCount += wasReleased;

    		global_keyDownStates[keyType].isDown = keyIsDown;
    	}

    } else {
    	result = DefWindowProcW(hwnd, msg, wparam, lparam);
    }

    return result;
} 
#ENDCODE

#HR

##<span id='id8'>Mouse Input</span>

Now that we've got our key input the next thing we want to do is handle mouse input. We're going to handle it similar to our key input, we just have to handle different messages: WM_LBUTTONDOWN, WM_LBUTTONUP, WM_RBUTTONDOWN, WM_RBUTTONUP, WM_MOUSEWHEEL and WM_MOUSEHWHEEL. Let's do this!

First we'll add some extra key states to our enum. And two float values to store the scroll value.

#CODE
	enum PlatformKeyType {
		PLATFORM_KEY_NULL,
		PLATFORM_KEY_UP,
		PLATFORM_KEY_DOWN,
		PLATFORM_KEY_LEFT,
		PLATFORM_KEY_RIGHT,
		PLATFORM_KEY_Z,
		PLATFORM_KEY_X,

		PLATFORM_MOUSE_LEFT_BUTTON,
		PLATFORM_MOUSE_RIGHT_BUTTON,

		//NOTE: Everthing before here
		PLATFORM_KEY_TOTAL_COUNT
	};

	static float global_mouseScrollY;
	static float global_mouseScrollX;

#ENDCODE

Now in our message callback we will set the values.

#CODE

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
    LRESULT result = 0;

    if(msg == WM_LBUTTONDOWN) {
    	if(!global_keyDownStates[PLATFORM_MOUSE_LEFT_BUTTON].isDown) {
    		global_keyDownStates[PLATFORM_MOUSE_LEFT_BUTTON].pressedCount++;
    	}
		
		global_keyDownStates[PLATFORM_MOUSE_LEFT_BUTTON].isDown = true;

    } else if(msg == WM_LBUTTONUP) {
    	global_keyDownStates[PLATFORM_MOUSE_LEFT_BUTTON].releasedCount++;
    	global_keyDownStates[PLATFORM_MOUSE_LEFT_BUTTON].isDown = false;

    } else if(msg == WM_RBUTTONDOWN) {
    	if(!global_keyDownStates[PLATFORM_MOUSE_RIGHT_BUTTON].isDown) {
    		global_keyDownStates[PLATFORM_MOUSE_RIGHT_BUTTON].pressedCount++;
    	}
		
		global_keyDownStates[PLATFORM_MOUSE_RIGHT_BUTTON].isDown = true;
    } else if(msg == WM_RBUTTONUP) {
    	global_keyDownStates[PLATFORM_MOUSE_RIGHT_BUTTON].releasedCount++;
    	global_keyDownStates[PLATFORM_MOUSE_RIGHT_BUTTON].isDown = false;

    } else if(msg == WM_MOUSEWHEEL) {
    	//NOTE: We use the HIWORD macro defined in windows.h to get the high 16 bits
    	short wheel_delta = HIWORD(wparam);
    	global_mouseScrollY = (float)wheel_delta;

    } else if(msg == WM_MOUSEHWHEEL) {
	    //NOTE: We use the HIWORD macro defined in windows.h to get the high 16 bits
	    short wheel_delta = HIWORD(wparam);
	    global_mouseScrollX = (float)wheel_delta;

    } else if(msg == WM_SYSKEYDOWN || msg == WM_SYSKEYUP || 
    message == WM_KEYDOWN || message == WM_KEYUP) {

    	//NOTE: Handling our key presses here 

    	//....

    } else {
    	result = DefWindowProcW(hwnd, msg, wparam, lparam);
    }

    return result;
} 


#ENDCODE

#HR

##<span id='id9'>Get Cursor Coordinates</span>
Great, we're handling mouse input. The last thing to fully handle the mouse is to retrieve the x, y coordinates of it. There isn't a message for this, we just query it each frame in our game loop. The code do this looks like this:

#CODE 
	POINT mouse;
	GetCursorPos(&mouse);
	//NOTE: hwnd is the window handle passed into our WinMain function
	ScreenToClient(hwnd, &mouse);
	float mouseX = (float)(mouse.x);
	float mouseY = (float)(mouse.y);

#ENDCODE
   
In the game loop we'll put it after our message loop. 

#CODE
	//NOTE: The Game Loop
	bool running = true;
	while(running) {

		//NOTE: Clear the key pressed and released count before processing our messages
		for(int i = 0; i < PLATFORM_KEY_TOTAL_COUNT; ++i) {
			global_keyDownStates[i].pressedCount = 0;
			global_keyDownStates[i].releasedCount = 0;
		}

		MSG message;
		while(PeekMessage(&message, 0, 0, 0, PM_REMOVE))
		{	
			if(message.message == WM_QUIT) {
				//NOTE: Exit our game loop
				running = false;
			}

		    TranslateMessage(&message);
		    DispatchMessage(&message); //NOTE: our message callback is handled here
		}

		//NOTE: get the mouse location
		POINT mouse;
		GetCursorPos(&mouse);
		//NOTE: hwnd is the window handle passed into our WinMain function
		ScreenToClient(hwnd, &mouse);
		float mouseX = (float)(mouse.x);
		float mouseY = (float)(mouse.y);

	}

#ENDCODE 

GetCursorPos retrieves the mouse location relative to the computer screen with the origin in the bottom left corner. We then use ScreenToClient to map the coordinates to be relative to the bottom left corner of our window.

#HR

##<span id='id10'>Platform Input Struct</span>

Well done, we did it. We're handling key input, mouse input and cursor location. To clean things up, instead of having multiple global variables, let's just put all the input into one struct.

#CODE
struct PlatformInputState {

	PlatformKeyState keyStates[PLATFORM_KEY_TOTAL_COUNT]; 

	//NOTE: Mouse data
	float mouseX;
	float mouseY;
	float mouseScrollX;
	float mouseScrollY;
}	

static PlatformInputState global_platformInput;

#ENDCODE

We'll then change our code to use this inputState instead of the seperate global variables. It's all the same as before just now accessing the array and mouseScroll values from the PlatformStruct. Our message callback will look like this.

#CODE
	LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
	    LRESULT result = 0;

	    if(msg == WM_CLOSE || msg == WM_DESTROY) {
	    	PostQuitMessage(0);
	    } else if(msg == WM_LBUTTONDOWN) {
	    	if(!global_platformInput.keyStates[PLATFORM_MOUSE_LEFT_BUTTON].isDown) {
	    		global_platformInput.keyStates[PLATFORM_MOUSE_LEFT_BUTTON].pressedCount++;
	    	}
			
			global_platformInput.keyStates[PLATFORM_MOUSE_LEFT_BUTTON].isDown = true;

	    } else if(msg == WM_LBUTTONUP) {
	    	global_platformInput.keyStates[PLATFORM_MOUSE_LEFT_BUTTON].releasedCount++;
	    	global_platformInput.keyStates[PLATFORM_MOUSE_LEFT_BUTTON].isDown = false;

	    } else if(msg == WM_RBUTTONDOWN) {
	    	if(!global_platformInput.keyStates[PLATFORM_MOUSE_RIGHT_BUTTON].isDown) {
	    		global_platformInput.keyStates[PLATFORM_MOUSE_RIGHT_BUTTON].pressedCount++;
	    	}
			
			global_platformInput.keyStates[PLATFORM_MOUSE_RIGHT_BUTTON].isDown = true;
	    } else if(msg == WM_RBUTTONUP) {
	    	global_platformInput.keyStates[PLATFORM_MOUSE_RIGHT_BUTTON].releasedCount++;
	    	global_platformInput.keyStates[PLATFORM_MOUSE_RIGHT_BUTTON].isDown = false;

	    } else if(msg == WM_MOUSEWHEEL) {
	    	//NOTE: We use the HIWORD macro defined in windows.h to get the high 16 bits
	    	short wheel_delta = HIWORD(wparam);
	    	global_platformInput.mouseScrollY = (float)wheel_delta;

	    } else if(msg == WM_MOUSEHWHEEL) {
		    //NOTE: We use the HIWORD macro defined in windows.h to get the high 16 bits
		    short wheel_delta = HIWORD(wparam);
		    global_platformInput.mouseScrollX = (float)wheel_delta;

	    } else if(msg == WM_SYSKEYDOWN || msg == WM_SYSKEYUP || 
	    message == WM_KEYDOWN || message == WM_KEYUP) {

	    	//NOTE: Handling our key presses here 

	    	bool keyWasDown = ((l_param & (1 << 30)) == 0);
	    	bool keyIsDown =   !(l_param & (1 << 31));

			WPARAM vk_code = wparam;    	

			PlatformKeyType keyType = PLATFORM_KEY_NULL; 

	    	//NOTE: match our internal key names to the vk code
	    	if(vk_code == VK_UP) { 
	    		keyType = PLATFORM_KEY_UP;
	    	} else if(vk_code == VK_DOWN) {
	    		keyType = PLATFORM_KEY_DOWN;
	    	} else if(vk_code == VK_LEFT) {
	    		keyType = PLATFORM_KEY_LEFT;
	    	} else if(vk_code == VK_RIGHT) {
	    		keyType = PLATFORM_KEY_RIGHT;
	    	} else if(vk_code == 'Z') {
	    		keyType = PLATFORM_KEY_Z;
	    	} else if(vk_code == 'X') {
	    		keyType = PLATFORM_KEY_X;
	    	}


	    	//NOTE: Key pressed, is down and release events  
	    	if(keyType != PLATFORM_KEY_NULL) {
	    		int wasPressed = (keyIsDown && !keyWasDown) ? 1 : 0;
	    		int wasReleased = (!keyIsDown) ? 1 : 0;

	    		global_platformInput.keyStates[keyType].pressedCount += wasPressed;
	    		global_platformInput.keyStates[keyType].releasedCount += wasReleased;

	    		global_platformInput.keyStates[keyType].isDown = keyIsDown;
	    	}

	    } else {
	    	result = DefWindowProcW(hwnd, msg, wparam, lparam);
	    }

	    return result;
	} 	

#ENDCODE

And our mouse position will use this as well to store it's values.

#CODE 
	//In our game loop

	//NOTE: get the mouse location
	POINT mouse;
	GetCursorPos(&mouse);
	//NOTE: hwnd is the window handle passed into our WinMain function
	ScreenToClient(hwnd, &mouse);
	global_platformInput.mouseX = (float)(mouse.x);
	global_platformInput.mouseY = (float)(mouse.y);

#ENDCODE 

#HR

##Creating a character buffer for text input

In a game you might want an actual string of characters that a user typed like entering in their profile name or entering commands into the in-game console. For this you want to handle the messages a bit different for three reasons:
1. So it obeys the keyboard repeat functionality (if you just used the <i>isDown</i> for a key, it would spew out be very hard to control the number of letters coming out because it's just down every frame). 
2. To handle unicode characters - virtual key codes don't contain unicode 
3. For the OS to handle Upper case and Lower case for us

To do this we use the WM_CHAR message. Each time we get this message we add the character to a buffer for that frame. 

We'll store the buffer in our PlatformInputState.

#CODE 

#define PLATFORM_MAX_TEXT_BUFFER_SIZE_IN_BYTES 256

struct PlatformInputState {

	PlatformKeyState keyStates[PLATFORM_KEY_TOTAL_COUNT]; 

	//NOTE: Mouse data
	float mouseX;
	float mouseY;
	float mouseScrollX;
	float mouseScrollY;

	//NOTE: Text Input
	uint8_t textInput_utf8[PLATFORM_MAX_TEXT_BUFFER_SIZE_IN_BYTES];
	int textInput_bytesUsed;
}	

static PlatformInputState global_platformInput;

#ENDCODE

Then in our message loop we'll handle the WM_CHAR message:

#CODE
	LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
	    LRESULT result = 0;

	   if(msg == WM_CHAR) {
	      uint32_t utf16_character = (uint32_t)wparam;

	      //NOTE: Convert the utf16 character to utf8

	      //NOTE: Get the size of the utf8 character in bytes
	      int bufferSize_inBytes = WideCharToMultiByte(
	        CP_UTF8,
	        0,
	        utf16_character,
	        1, //NOTE: character not null terminated, so specify it's only one character long
	        (LPSTR)global_platformInput.textInput_utf8, 
	        0,
	        0, 
	        0
	      );

	      //NOTE: See if we can still fit the character in our buffer
	      if((global_platformInput.textInput_bytesUsed + bufferSize_inBytes) <= PLATFORM_MAX_TEXT_BUFFER_SIZE_IN_BYTES) {
	      		
	      	//NOTE: Add the utf8 value of the character to our buffer
	      	u32 bytesWritten = WideCharToMultiByte(
	      	  CP_UTF8,
	      	  0,
	      	  utf16_character,
	      	  -1,
	      	  (LPSTR)(global_platformInput.textInput_utf8 + global_platformInput.textInput_bytesUsed), 
	      	  bufferSize_inBytes,
	      	  0, 
	      	  0
	      	);

	      	//NOTE: Increment the buffer size
	      	global_platformInput.textInput_bytesUsed += bufferSize_inBytes;

	      }
	      
	   } else //... rest of our messages



#ENDCODE

We get the character code from the wparam. This is a utf-16 encoded character. Depending on how you'll use this string you'll want to convert it to it's utf-8 equivalent. We use the windows function <i>WideCharToMultiByte</i> to do this for us. We first get the size of the utf-8 character in bytes, then if it fits in our buffer, we'll convert it, putting the result in our buffer.  
   

##NOTES

[1] If we're really processing only the last message that we recieved each frame, wouldn't we get multiple WM_KEYDOWN messages in a frame when we start pressing a key? Causing us to not register any key press events? Luckily, Windows and most Operating Systems has a Keyboard Repeat functionality causing a slight delay between the first WM_KEYDOWN message of a key press and subsequent WM_KEYDOWN messages. This means in a single frame, it's unlikely we will see a second WM_KEYDOWN message for a key press.

[2] You can test your keyboard scan rate <a href=https://blog.seethis.link/scan-rate-estimator/> at this link </a>. <a href='https://www.reddit.com/r/MechanicalKeyboards/comments/k2mb4x/keyboard_polling_ratescan_rate_help/'>The answer on this thread gives a detailed explanation on Poll Rate vs Scan Rate of a keyboard.</a>
