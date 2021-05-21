#CARD
#TITLE Using DirectX 11 for games: Part 1
#CARD
#ANCHOR https://github.com/kevinmoran/BeginnerDirect3D11 This series is based on Kevin Moran's brilliant DirectX tutorial code which you can get here

In this article, I’m going to walk through creating a DirectX 11 context to use with your games. DirectX 11 is the native graphics API for Windows. DirectX has advantages over OpenGL in that it is more reliable on Windows computers — this is an advantage when it comes time to ship your game. You want it to work on as many machines as possible with the least hiccups. You don’t want half your users (or worse!) to load your game up and find a blank screen. The other advantage over OpenGL is that DirectX is a lot easier to reason about. OpenGL is a giant state machine where you bind textures, vertex arrays, and options like blend modes which stay bound until you specifically unbind them or unset them. This can lead to bugs that can be hard to find. DirectX 11 API is less of a state machine, and more function calls that you can reason, making the experience of graphics program more enjoyable.


#HR

###Our Entry Point

Let's get started! The first thing for any Windows program is the windows entry point which we’re going to stick into a main.cpp file:

#CODE
include <windows.h>
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE /*hPrevInstance*/, LPSTR /*lpCmdLine*/, int /*nShowCmd*/) {
return 0;
}
#ENDCODE

We’ve commented out the variables we don’t use in our program — we only use the first variable of the function, the hInstance — this is the instance of our exe running, which we’re going to need to create a window.
We can compile this to make sure everything is working. We’re using the MSVC compiler from the command line so we’re going to type:

#CODE
cl main.cpp
#ENDCODE

Great! Hopefully, there aren’t any compiler errors. Next, we’re going to declare a window class. This is something you create to choose the settings for the window we want to create. It looks something like this:

#CODE
//First register the type of window we are going to create
WNDCLASSEXW winClass = {};
winClass.cbSize = sizeof(WNDCLASSEXW);
winClass.style = CS_HREDRAW | CS_VREDRAW;
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

1. Put the define unicode at the top of our file. This tells other windows functions we’re supporting unicode so please help us.

2. Put L before a string literal. This tells the compiler to treat the string as a wide string (2 bytes per character). This looks like this L”MyWindowClass”.

#ANCHOR http://www.cplusplus.com/forum/articles/16820/ You can read more about Unicode support on windows here
The main thing to notice here is that we want a window that redraws when it is resized. We do this by passing the flags <i>CS_HREDRAW | CS_VREDRAW</i>. We’re also passing a pointer to a function called WndProc seen in the line <i>winClass.lpfnWndProc = &WndProc;</i>
<img src='./photos/directX_lesson1_pictures/directx03.png' style='width: 60%;'>
This is the callback that handles events sent to our app like resizing, keyboard input, and exiting our program. We have to define it ourselves, so we’ll do that above our main function.
#CODE
LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
    LRESULT result = 0;
    switch(msg) {
        case WM_KEYDOWN: {
            if(wparam == VK_ESCAPE)
                PostQuitMessage(0);
            break;
        }
        case WM_DESTROY: {
            PostQuitMessage(0);
        } break;
        default:
            result = DefWindowProcW(hwnd, msg, wparam, lparam);
    }
    return result;
}
#ENDCODE
You’ll see that we’re handling the WM_KEYDOWN event in which we check if the key is escape. If so we destroy our window. We also handle the WM_DESTROY event, which we post a QuitMessage which we’ll handle in our message loop. All other events we give to the default function.
Next we’ll actually create our window.
<img src='./photos/directX_lesson1_pictures/directx01.png' style='width: 50vw;'>
#CODE
//Now create the actual window
        RECT initialRect = { 0, 0, 960, 540 };
        AdjustWindowRectEx(&initialRect, WS_OVERLAPPEDWINDOW, FALSE, WS_EX_OVERLAPPEDWINDOW);
        LONG initialWidth = initialRect.right - initialRect.left;
        LONG initialHeight = initialRect.bottom - initialRect.top;

HWND hwnd = CreateWindowExW(WS_EX_OVERLAPPEDWINDOW,
                                winClass.lpszClassName,
                                L"Direct X Window - not yet",
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
We use the CreateWindowExW to actually create our window. We give it the windowclass we created before and give the window a name. We also are passing our hInstance (the handle to our exe) and some initial flags — WS_OVERLAPPEDWINDOW | WS_VISIBLE (we want a normal window type and we want our window to be visible). We also pass the initial size of our window. There is something to note here — the initial width & height of the window include the border, to get the actually inner dimension to be what we want we have to use
#CODE
AdjustWindowRectEx(&initialRect, WS_OVERLAPPEDWINDOW, FALSE, WS_EX_OVERLAPPEDWINDOW);
#ENDCODE
We pass in the dimensions we want for our inner window, and it gives back the dimensions including the border that we should pass to CreateWindow.
<img src='./photos/directX_lesson1_pictures/directx02.png' style='width: 50vw;'>
Great! If we compile this now we should see a window briefly appear then disappear again. Let’s do that.
To compile is now we need to pass a linker flag since we’re using functions that live in <i>user32.lib</i>
#CODE
cl main.cpp /link user32.lib
#ENDCODE
Now when we run this and run our main.exe, we should see our window briefly appear. To finish this lesson of we’re going to add the infamous game loop.
#HR
###The Game Loop
<img src='./photos/directX_lesson1_pictures/directx04.png' style='width: 50vw;'>
Below our CreateWindow function, we’ll write this:
#CODE
bool running = true;
while(running) {
}
#ENDCODE
If we ran this we’d be stuck in an infinite loop since we don’t handle our messages — specifically our exit message. This is where our WndProc callback is handled to process the events we received. We are going to use PeekMessage instead of GetMessage to receive our events. The difference is that GetMessage stays waiting for messages to process, instead of continuing on with the program. For a game you want PeekMessage.
#CODE
bool running = true;
while(running) {
MSG msg = {};
        while(PeekMessageW(&msg, 0, 0, 0, PM_REMOVE))
        {
            if(msg.message == WM_QUIT) {
                running = false;
            }
            TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }
}
#ENDCODE
Our WndProc callback is called via DispatchMessage. So all input is processed there. You’ll see we handle the WM_QUIT message here by setting running to false. This is when we press the Red X button or we press escape because we handle this in our wndProc callback.
Now if we compile it using the same code as above (cl main.cpp /link user32.lib) and run it, we’ll get a window that stays open. We can quit it by pressing the Red X or pressing escape.
Awesome! Well done. We’re on our way to getting a directX renderer going.
#ANCHOR https://github.com/Olster1/directX11_tutorial/blob/main/lesson1/main.cpp You can see all the code up to this point here
#HR
##Start using DirectX 
Ok next we’re actually going to jump into using DirectX. First we need to include the directX header file at the top of our main.cpp file.
#CODE
include <d3d11_1.h>
#ENDCODE
First we’re going to create two things — a d3d11device and a d3d11DeviceContext. When we create a device, we’re specifying what type of d3d features we want (just d3d11, or d3d9 and d3d10 aswell?), whether we want software or hardware (using the GPU) rendering? And what type of pixel format do we want to support?


<img src='./photos/directX_lesson1_pictures/directx1.png' style='width: 60%;'>


The device is in charge of creating resources (like shaders, frame buffers, and vertex buffers)and talking to the video adapter. You only want to create one device per program.
A device context on the other hand contains the circumstances or setting in which the device is used. It’s specifically used to generate render commands using the resources owned by the device. We use the d3ddevice to create resources like shaders, vertex buffers, textures & framebuffers. And we use the device context to set the render states like setViewport, setShader, setVertexBuffers and submit draw calls — the context in which we are using our resources.
To create these two things we use function D3D11CreateDevice, passing in a pointer to a ID3D11Device and a pointer to ID3D11DeviceContext to be filled out. It looks like this:
#CODE
ID3D11Device* baseDevice;
        ID3D11DeviceContext* baseDeviceContext;
        D3D_FEATURE_LEVEL featureLevels[] = { D3D_FEATURE_LEVEL_11_0 }; //we just want d3d 11 features, not below
        UINT creationFlags = D3D11_CREATE_DEVICE_BGRA_SUPPORT; 
    #if defined(DEBUG_BUILD)
        creationFlags |= D3D11_CREATE_DEVICE_DEBUG;
        #endif 
HRESULT hResult = D3D11CreateDevice(0, D3D_DRIVER_TYPE_HARDWARE, //hardware rendering instead of software rendering
                                            0, creationFlags, 
                                            featureLevels, ARRAYSIZE(featureLevels),
                                            D3D11_SDK_VERSION, &baseDevice, 
                                            0, &baseDeviceContext);
        if(FAILED(hResult)){
            MessageBoxA(0, "D3D11CreateDevice() failed", "Fatal Error", MB_OK);
            return GetLastError();
        }
#ENDCODE
We want Direct11 features, hardware rendering, a device with BGRA support and in a debug build we want to create a debug device to find errors in our program.
There’s one more catch here. There are newer versions of ID3D11DeviceContext and ID3D11DeviceContext aptly called ID3D11Device1 and ID3D11DeviceContext1 which have more functionality. Since we would rather have these, we query the device we just created to get a newer one. It looks like this:
#CODE
ID3D11Device1* d3d11Device;
ID3D11DeviceContext1* d3d11DeviceContext;
// Get 1.1 interface of D3D11 Device and Context
hResult = baseDevice->QueryInterface(__uuidof(ID3D11Device1), (void**)&d3d11Device);
assert(SUCCEEDED(hResult));
baseDevice->Release();
hResult = baseDeviceContext->QueryInterface(__uuidof(ID3D11DeviceContext1), (void**)&d3d11DeviceContext);
assert(SUCCEEDED(hResult));
baseDeviceContext->Release();
#ENDCODE
We use QueryInterface to get the type of ID3D11Device1 from our device. And the same on our deviceContext. We then release the original device and device context.
Awesome! Now we can check if this compiles. We’re going to link to d3d11.lib for it to work. Our command line build script would now look like this:
#CODE
cl main.cpp /link user32.lib d3d11.lib
#ENDCODE
Also make sure you include assert at the top of main.cpp
#CODE
include <assert.h>
#ENDCODE
#HR
###Activate the Debug Layer
Great! Next we’re going to activate the debug layer in our deviceContext. You saw when we made the deviceContext, we asked for a debug compatible context with the flag D3D11_CREATE_DEVICE_DEBUG. To enable break on d3d errors we again query the deviceContext.
#CODE
#ifdef DEBUG_BUILD
    // Set up debug layer to break on D3D11 errors
    ID3D11Debug *d3dDebug = nullptr;
    d3d11Device->QueryInterface(__uuidof(ID3D11Debug), (void**)&d3dDebug);
    #if (d3dDebug)
    {
        ID3D11InfoQueue *d3dInfoQueue = nullptr;
        if (SUCCEEDED(d3dDebug->QueryInterface(__uuidof(ID3D11InfoQueue), (void**)&d3dInfoQueue)))
        {
            d3dInfoQueue->SetBreakOnSeverity(D3D11_MESSAGE_SEVERITY_CORRUPTION, true);
            d3dInfoQueue->SetBreakOnSeverity(D3D11_MESSAGE_SEVERITY_ERROR, true);
            d3dInfoQueue->Release();
        }
        d3dDebug->Release();
    }
#endif
#ENDCODE
We get the ID3D11Debug object from our device using QueryInterface. Once we’ve got that, we can get the d3dInfoQueue from it. We then use the SetBreakOnSeverity function to say what errors we want to break on. 
#ANCHOR https://docs.microsoft.com/en-us/windows/win32/api/d3d12sdklayers/ne-d3d12sdklayers-d3d12_message_severity You can see other options to set in this link.
#HR
###Make the Swap Chain

<img src='./photos/directX_lesson1_pictures/directx2.png' style='width: 60%;'>

The next step is to create a SwapChain. This is a collection of buffers that are used for displaying frames to the user. We render to one of these buffers in the swap chain while one is drawn to the screen. More than one buffer is used to avoid tearing. This happens when we try render to the same buffer while it’s being drawn to the monitor, resulting in an old image on the upper half of the screen, with the new image on the lower one. Instead we have 2 or more buffers that we can ping-pong between. We draw to one (named the backbuffer), while the other is being displayed to the user.

<img src='./photos/directX_lesson1_pictures/directx3.png' style='width: 60%;'>

To create the SwapChain we first need to create DXGI Factory which is used for generating objects that handle fullscreen transitions (namely the swapchain). It’s another case of using QueryInterface and other helper functions to drill down and get the final object we need. It looks like this:
#CODE
// Get DXGI Factory (needed to create Swap Chain)
IDXGIFactory2* dxgiFactory;
{
// First, retrieve the underlying DXGI Device from the D3D Device      IDXGIDevice1* dxgiDevice;
 HRESULT hResult = d3d11Device->QueryInterface(__uuidof(IDXGIDevice1), (void**)&dxgiDevice);
            assert(SUCCEEDED(hResult));
// Identify the physical adapter (GPU or card) this device is running on.
IDXGIAdapter* dxgiAdapter;
            hResult = dxgiDevice->GetAdapter(&dxgiAdapter);
            assert(SUCCEEDED(hResult));
            dxgiDevice->Release();
DXGI_ADAPTER_DESC adapterDesc;
            dxgiAdapter->GetDesc(&adapterDesc);
//the graphics card that is being used by this progam 
OutputDebugStringA("Graphics Device: ");
OutputDebugStringW(adapterDesc.Description);
// And obtain the factory object that created it.
hResult = dxgiAdapter->GetParent(__uuidof(IDXGIFactory2), (void**)&dxgiFactory);
            assert(SUCCEEDED(hResult));
            dxgiAdapter->Release();
        }
#ENDCODE
We get the dxgiDevice from our d3d11Device. Then we call GetAdapter we gives us back the video adapter (IDXGIAdapter) directX is using — this represents your graphics card. We can see specifically what it is, using the GetDesc function on it as seen above-in my case it’s using the integrated graphics card.
The parent of the adpater is the dxgiFactory that was created when we create our d3d11Device. Phew! We’ve got our dxgiFactory that is in charge of creating the SwapChain[1]. So now let’s create it!
#HR
Now we will create our SwapChain. We use the function CreateSwapChainForHwnd. We also need to create the description of the buffer we want to create. What pixel format it will be in (we want 8bits per color B8G8R8A8 also want the output to be SRGB). The width and height of it. Whether it is a multi-sample buffer. How many buffers we want in our swapchain (we want at least 2 to avoid tearing). How we want our back buffer to respond when the window is a different aspect-ratio and size.

This is what that looks like:
#CODE
DXGI_SWAP_CHAIN_DESC1 d3d11SwapChainDesc = {};
            d3d11SwapChainDesc.Width = 0; // use window width
            d3d11SwapChainDesc.Height = 0; // use window height
            d3d11SwapChainDesc.Format = DXGI_FORMAT_B8G8R8A8_UNORM_SRGB;
            d3d11SwapChainDesc.SampleDesc.Count = 1;
            d3d11SwapChainDesc.SampleDesc.Quality = 0;
            d3d11SwapChainDesc.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
            d3d11SwapChainDesc.BufferCount = 2;
            d3d11SwapChainDesc.Scaling = DXGI_SCALING_STRETCH;
            d3d11SwapChainDesc.SwapEffect = DXGI_SWAP_EFFECT_DISCARD;
            d3d11SwapChainDesc.AlphaMode = DXGI_ALPHA_MODE_UNSPECIFIED;
            d3d11SwapChainDesc.Flags = 0;
#ENDCODE
Since these are the buffers that we are drawing to, we set the BufferUsage to DXGI_USAGE_RENDER_TARGET_OUTPUT. Since we aren’t reading from the buffer, we don’t care about the alphaMode. We also must choose an option for how the buffer is presented to the screen in the SwapEffect variable. Since we are rendering the complete scene from scratch into the buffer each frame, we don’t need to rely on past rendering to still exist in the buffer. Because of this we use the swap effect DXGI_SWAP_EFFECT_DISCARD, instead of the DXGI_SWAP_EFFECT_SEQUENTIAL [2].

Now that we’ve got our SwapChainDescription, we are ready to create it using CreateSwapChainForHwnd, passing in our device, our description and our windowHandle:
#CODE
HRESULT hResult = dxgiFactory->CreateSwapChainForHwnd(d3d11Device, hwnd, &d3d11SwapChainDesc, 0, 0, &d3d11SwapChain);
            assert(SUCCEEDED(hResult));
dxgiFactory->Release();
#ENDCODE
We also release our pointer to the dxgiFactory since we no longer need it.
#HR
###Create a Render View Target

<img src='./photos/directX_lesson1_pictures/directx4.png' style='width: 60%;'>

Ok, we’ve got our d3d11Device, our d3d11DeviceContext and our SwapChain. We these three things we are able to render to our window.
The very last thing we need to do before we do this is to get access to the backbuffer in our SwapChain to draw to. This is represented as a ID3D11RenderTargetView, which looks after the writable part ofwhat we’re rendering into. 

To get this from the backbuffer in our SwapChain we do the following:
#CODE
// Create Framebuffer Render Target
    ID3D11RenderTargetView* d3d11FrameBufferView;
    {
        ID3D11Texture2D* d3d11FrameBuffer;
        HRESULT hResult = d3d11SwapChain->GetBuffer(0, __uuidof(ID3D11Texture2D), (void**)&d3d11FrameBuffer);
        assert(SUCCEEDED(hResult));
hResult = d3d11Device->CreateRenderTargetView(d3d11FrameBuffer, 0, &d3d11FrameBufferView);
        assert(SUCCEEDED(hResult));
        d3d11FrameBuffer->Release();
    }
#ENDCODE
We use the GetBuffer function from our swapChain, passing the buffer index as zero, since this is the only buffer we can acces with the swap effect DXGI_SWAP_EFFECT_DISCARD. Once we get it, we can then create a RenderTargetView.
So we’ve got all the tools to do the rendering for us (the deviceContext and swapchain) and we’ve got the buffer we’re going to render into — the RenderTargetView of the backbuffer.
Time to get rendering!
#HR
###Using DirectX in our game loop
<img src='./photos/directX_lesson1_pictures/directx5.png' style='width: 60%;'>

In our game loop, after we’ve processed our messages, we’re going to clear the renderTarget to a blue color. It looks like this:
#CODE
MSG msg = {};
        while(PeekMessageW(&msg, 0, 0, 0, PM_REMOVE))
        {
            if(msg.message == WM_QUIT)
                isRunning = false;
            TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }
FLOAT backgroundColor[4] = { 0.1f, 0.2f, 0.6f, 1.0f };
        d3d11DeviceContext->ClearRenderTargetView(d3d11FrameBufferView, backgroundColor);
#ENDCODE
We’re using our d3d11DeviceContext which looks after the rendering commands to clear a render targetView — the backbuffer one we created.

#HR
###Present Our Frame

<img src='./photos/directX_lesson1_pictures/directx6.png' style='width: 60%;'>

Then to finish the frame off we use our swapchain, calling present. This says we’re done all rendering for this frame, it’s time to present. This is the equivalent to the OpenGL command wglSwapBuffers.

#CODE
d3d11SwapChain->Present(1, 0);
#ENDCODE

The first argument is the sync interval-how were syncing with V-sync. A zero means don’t wait for v-sync, just display the image now. A value 1 to 4 means synchronize presentation after these number of vsyncs. i.e how many number of vsyncs we wait for till we can keep rendering. We want to keep up with the montior refresh rate, so we choose one. This value is the same as <i>wglSwapIntervalEXT()</i> with openGL.

The second argument is how we want to present the frames to the output. A zero means we present a frame from each buffer starting with the current buffer — that is we’re using the sequencing ability of writing to one frame while the other one is being read, and flipping them on present.

#HR

We made it. When we compile the game and run it we should hopefully get a light blue screen.

<img src='./photos/directX_lesson1_pictures/directx_blue_screen.png' style='width: 60%;'>

#ANCHOR https://github.com/Olster1/directX11_tutorial/blob/main/lesson2/main.cpp You can see the full code here

#ANCHOR https://github.com/Olster1/directX11_tutorial/blob/main/lesson2_withTiming/main.cpp You can also find a version that mesures the frame time here (you need to run it in Visual Studio to see the Console Output)

#HR

You made it through the whole Part 1 lesson. Congratulate yourself! It’s no mean feat doing computer graphics at a low level.

In Part 2 we’ll render a colorful triangle to the screen, well on the way to rendering full 3d models. See you then!

#ANCHOR https://oliver532.substack.com/p/coming-soon?r=9i1j7&utm_campaign=post&utm_medium=web&utm_source=copy Sign up to my Newsletter to get a weekly email about what I’m up to, what I’m learning and what I’m teaching.

#HR

##QUIZ

<b>What function to we use to create a Window?</b>
[CreateWindowExW]

<b>What do we need to pass to CreateWindow?</b>
[A windowClass which we register before creating a window. It also contains the function pointer to out event callback wndProc for handling input]
<b>What do we do at the start of every game loop?</b>
[We process the messages that have come in using PeekMessage.]
<b>When is our WndProc function called?</b>
[When we use DispatchMessage()]
<b>What were the four directX objects we needed to create before rendering to our Window?</b>
[d3d11Device, d3d11DeviceContext, IDXGISwapChain, and a ID3D11RenderTargetView. At least one Device is needed to use DirectX. It’s in charge of creating resources. The DeviceContext is used to set the state in which we will use GPU. We use the DeviceContext the most during rendering our scene. The RenderTargetView represents the buffer we’re drawing into]
<b>What function submits our final buffer to the GPU?</b>
[swapChain->Present() function. It takes two parameters: the sync interval and how we want to display the buffers]
<b>Why do we need at least two buffers in the swap chain?</b>
[To stop tearing — that is we start updating the buffer that is being displayed to the screen, causing one half of the buffer to be the original image and the other half the new one we are writing to it. Instead, we ping pong between the buffers in the SwapChain]
#HR
##Notes:
[1] It should be noted you can just use D3D11CreateDeviceAndSwapChain which creates both at the same time. It was separated to show more of what is happening behind the scenes.
[2] There are newer versions of these values: DXGI_SWAP_EFFECT_FLIP_DISCARD and DXGI_SWAP_EFFECT_FLIP_SEQUENTIAL which are recomended to be used. Although these are only avaiable on Windows 10
