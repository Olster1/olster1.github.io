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

In this tutorial we'll do four things: 

1. Get our .exe path
2. Remove the exe name 
3. Append our new file location
4. Convert the string from utf-16 to utf-8

#HR

###Get the .exe path using the Win32 API
#CODE

WCHAR resourcesPath[MAX_PATH];
int sizeOfPath = GetModuleFileNameW(NULL, resourcesPath, ARRAYSIZE(resourcesPath));

//NOTE: Assert if function failed
if(sizeOfPath == 0) {
    assert(!"get module file name failed");
}

#ENDCODE

We use the Windows function <i>GetModuleFileNameW</i> to get the file path of our exe. We can pass NULL as the first argument because we want it for the process running this function. We also pass the buffer we want to be filled out and the size. We then assert the function worked. 

To be unicode compatible, we use the WCHAR type for the buffer to be filled out, and use the MAX_PATH macro for the size of the buffer.

#HR

###Alter the string

Now that we have the file path, we can create our our resource folder string. Say if we have a folder like above call <i>resources</i> in the same folder as our exe, we'll want to remove the exe path, and replace it with the string <i>resources\</i>. We could do this ourselves but Windows already has a function to do this for us. First we'll remove the .exe off the end of our string. 

#CODE

PathRemoveFileSpecW(resourcesPath);

#ENDCODE

Great, we've remove the trailing exe and the slash preceding it. Our string should now look like this <i>C:\\Users\myName\Documents\awesome_game</i>

Now we'll add the folder name our resources are in. Again we could do this manually, but Windows has a handy function that does it for us.

#CODE

PathAppendW(resourcesPath, L"resources\\");

#ENDCODE

There we have it. With just three functions we've created the absolute path to our game resources. Since this string is utf-16, we may want to convert it to utf-8.

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

Before we compile it, we'll add the Windows header since we are using windows functions and data types. To use <i>PathRemoveFileSpecW</i> and <i>PathAppendW</i> we have to include the header <i>shlwapi.h</i> and link to <i>Shlwapi.lib</i> in our build script.

#CODE
#include <shlwapi.h>
#include <windows.h>
#ENDCODE

Our build script:

#CODE
cl -Od -Zi main.cpp /link Shlwapi.lib
#ENDCODE

Od and Zi being so I can debug it in Visual Studio and see the if the string we make is correct!  

Hope you enjoyed this article. Happy game making!

#ANCHOR https://github.com/Olster1/windows_tutorials/blob/main/getExePath_function/main.cpp The full code can be found here

Thanks for reading!