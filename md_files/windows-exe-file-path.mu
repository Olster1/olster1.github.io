#CARD
#TITLE Get your .exe file path on Windows

#HR 

If your making a game in Windows, your're going to want to get the path to your game exe. Since a user can put your game whereever they want, you don't specifically know where your resources like texture, sounds, fonts and models will be on their computer. <b>You only know they'll be in a specific folder relative to your .exe.</b> If we know this, we can work backward and make the absolute file name to access our game resources. 

For example if the user puts the game in their <i>Documents</i> folder, the exe path would look something like this:

#CODE
C:\\Users\myName\Documents\awesome_game\awesome_game.exe
#ENDCODE

Once we have this file path, we can alter it to find our game resources. For example if our resources are located at this address:


#CODE
C:\\Users\myName\Documents\awesome_game\resources\
#ENDCODE

And a font file address might look like this:

#CODE
C:\\Users\myName\Documents\awesome_game\resources\Arial_font.tff
#ENDCODE

We can alter our original exe string, removing the exe off the end and replacing it with <b>resources</b> and the resource name.

In this tutorial we'll do two things: 

1. Get our .exe path using the Win32 API
2. Alter this string to make our resource path string

#HR

###Get the .exe path using the Win32 API
#CODE

const WCHAR executablePath[MAX_PATH + 1]; //NOTE: Use WCHAR type to be unicode compatible 

DWORD size_of_executable_path =
            GetModuleFileNameW(0, executablePath, sizeof(executablePath)); //NOTE: Use the wide version of the function to be unicode compatible

//NOTE: Assert if function failed
if(size_of_executable_path == 0) {
    assert(!"get module file name failed");
}

#ENDCODE

We use the Windows function <i>GetModuleFileNameW</i> to get the file path of our exe. We can pass zero as the first argument because we want it for the process running this function. We then assert the function worked. To be unicode compatible, we use the WCHAR type for the buffer we'll store the name in, and use the MAX_PATH macro for the size of the buffer. We add 1 to it to account for the null terminator.

#HR

###Alter the string

Now that we have the file path, we can get our resource folder. Say if we have a folder like above call <i>resources</i> in the same folder as our exe, we'll want to remove the exe path, and replace it with the string <i>resources\</i>.

#CODE

WCHAR resourcesPath[MAX_PATH + 1]; //NOTE: Use WCHAR type to be unicode compatible 

WCHAR stringToAppend = L"resources\"; //NOTE: The L converts the string to a wide string (utf-16) 

memcpy(resourcesPath, executablePath, size_of_executable_path*sizeof(WCHAR)); //NOTE: Copy over the exe string so we don't alter the executable path

//NOTE: Find the last backslash in the path

WCHAR *one_past_last_slash = resourcesPath;
for(int i = 0; i < size_of_executable_path; ++i) {

    if(resourcesPath[i] == L'\\') {
        one_past_last_slash = resourcesPath + i + 1;
    }
}

#ENDCODE

So far we've copied over the executable string to a new buffer. We then loop through all the characters in the buffer and see if they are a back slash. Each time we encounter a new one, it becomes the new last slash. Now that we know where to start, we can append our <i>"resources\"</i> string.

#CODE

//NOTE: Loop through the string to append and add it to the buffer
WCHAR *at = stringToAppend;

int charIndex = 0;
while(*at) {
        
    one_past_last_slash[charIndex] = *at;

    assert(((one_past_last_slash + charIndex) - resourcesPath) <= MAX_PATH*sizeof(WCHAR)); //NOTE: Make sure we haven't overwritten the length of the buffer

    charIndex++;
    at++;
}

//NOTE: Null terminate the string 
one_past_last_slash[charIndex] = L'/0';

#ENDCODE

There we have it. We looped through the string to append and added each character to the buffer. We know we're not going to overflow the buffer because file paths can only be MAX_PATH long. We assert just to make sure we don't overflow the buffer. 

#HR

###Convert to utf-8

If the rest of our game engine expects to use utf-8 instead of Windows utf-16, we will want to convert it to utf-8. Like other tutorials on this site, we use the trusty <i>WideCharToMultiByte</i> function. 

#CODE 

///////////////////////************* Convert the string now to utf8 ************////////////////////

u8 *resourcePath_as_utf8 = 0;

int bufferSize_inBytes = WideCharToMultiByte(
  CP_UTF8,
  0,
  resourcesPath,
  -1,
  (LPSTR)resourcePath_as_utf8, 
  0,
  0, 
  0
);


resourcePath_as_utf8 = (u8 *)malloc(bufferSize_inBytes);

u32 bytesWritten = WideCharToMultiByte(
  CP_UTF8,
  0,
  resourcesPath,
  -1,
  (LPSTR)resourcePath_as_utf8, 
  bufferSize_inBytes,
  0, 
  0
);

assert(bytesWritten == bufferSize_inBytes);

#ENDCODE

We first find the size of the buffer we need to allocate. We then allocate it using malloc. Finally we use the same function again, but this time we bass in our newly created buffer. 

#HR

###Conclusion

We did it! We've now got an <b>absolute</b> path to our game's resources. We can use this now to access them without crashing since it knows where they'll be. 

Before we compile it, we'll add the Windows header since we are using windows functions and data types. We also define <i>UNICODE</i>, telling windows we want to be Unicode compatible, so please help us!

#CODE
#define UNICODE
#include <windows.h>
#ENDCODE

Hope you enjoyed this article. Happy game making!

#ANCHOR https://github.com/Olster1/windows_tutorials/blob/main/getExePath_function/main.cpp The full code can be found here

Thanks for reading!