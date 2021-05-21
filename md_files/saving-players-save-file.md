#CARD
#TITLE Saving player’s save file to a safe location

#HR 

If you're familiar with games on Windows, you may have come across the <b>UserName/SavedGames</b> folder. Each user on the computer has their own SavedGames folder and is the default place to save things like a player's save state.

Why can’t you just save it to the folder your game is installed in?

Different users on the computer might not want another user seeing their save state.

And, importantly from a programming standpoint, depending on where the user installs your game, you might not have permission to write to your game folder. Making the game either crash or not save the player’s progress, either one not good.

So the solution to this is saving it in a file location that is unique to each user and the os expects things to write in this location. This is what the SavedGames/ folder is for-saving things like user settings and progress files, which can be loaded up again when the user starts the program again.

In your code, you might want to create a function called getSaveFileLocation(). This would return the full file path to the folder.

#CODE
char *getSaveFileLocation() {
  char *result = 0;
  //find the file path here
  return result;
}
#ENDCODE

To get the filepath we use the Windows specific function SHGetKnownFolderPath, passing in the folder Id we want-FOLDERID_SavedGames. It looks like this:

#CODE
PWSTR  win32_wideString_utf16 = 0;
if(SHGetKnownFolderPath(
   FOLDERID_SavedGames,
   KF_FLAG_CREATE,
   0,
   (PWSTR *)&win32_wideString_utf16
 ) != S_OK) {
  assert(false);
  return result;
 }
#ENDCODE

We pass in a pointer to a wide string to be filled out since windows use wide strings (2 bytes per character) for Unicode. We want to create this folder if it doesn’t exist by passing in KF_FLAG_CREATE. And we assert false if this function doesn’t succeed.

This would be it if our program was using wide strings. But unfortunately (or fortunately!) most applications deal with utf8 encoded strings. So we have to do another step of converting it to utf8. Let’s do this:

#CODE
int bufferSize_inBytes = WideCharToMultiByte(
   CP_UTF8,
   0,
   win32_wideString_utf16,
   -1,
   (LPSTR)result, 
   0,
   0, 
   0
 );
#ENDCODE

By passing in no buffer length (argument 6), it just gives the resulting string length in bytes that we need to allocate.

Once we get that back we can now allocate it however you would like to allocate the string. We’re going to use malloc for instructional purposes.

#CODE
result = malloc(bufferSize_inBytes);
#ENDCODE

We then call the same function as above, but this time passing in the buffer size.

#CODE
u32 bytesWritten = WideCharToMultiByte(
   CP_UTF8,
   0,
   win32_wideString_utf16,
   -1,
   (LPSTR)result, 
   bufferSize_inBytes,
   0, 
   0
 );
 #ENDCODE

Yay! We’ve got our utf8 encoded string of the location of Local folder. 

We can make sure we got the full string that we’re supposed to get.

#CODE
assert(bytesWritten == bufferSize_inBytes);
#ENDCODE

We then free the wide string like so:

#CODE
//NOTE: Free the string
 CoTaskMemFree(win32_wideString_utf16);
#ENDCODE

We also have to include the header that contains the functions & enums that we’re using.

#CODE
#include <Shlobj.h>
#ENDCODE

Now finally we have to link to the correct .libs — CoTaskMemFree is in Ole32.lib and SHGetKnownFolderPath is in Shell32.lib.

#CODE
cl main.cpp /link Shell32.lib Ole32.lib
#ENDCODE

#ANCHOR https://github.com/Olster1/windows_tutorials/blob/main/appData_local_function/main.cpp The full code can be found here

Thanks for reading!