#CARD
#TITLE Direct3d 11 for games: Part 5
##Using a Constant Buffer
#CARD

Eaxh time the vertex is drawn (whether that's in a 2d image or a 3d model), it has a local position specified in the vertex buffer we send to the GPU. For example with a quad (2 triangles) from our last lesson, the data looked like this: 

#CODE
float vertexData[] = { // x, y, u, v
            -0.5f,  0.5f, 0.f, 0.f,
            0.5f, -0.5f, 1.f, 1.f,
            -0.5f, -0.5f, 0.f, 1.f,
            -0.5f,  0.5f, 0.f, 0.f,
            0.5f,  0.5f, 1.f, 0.f,
            0.5f, -0.5f, 1.f, 1.f
        };
#ENDCODE

So each side is size 1. If we want to position each vertex value we could do something like this: 

#CODE
float xPosition = 10; //quad center x
float yPosition = 10; //quad center y

float vertexData[] = { 
            xPosition + -0.5f,  yPosition + 0.5f, 0.f, 0.f,
            xPosition + 0.5f, yPosition + -0.5f, 1.f, 1.f,
            xPosition + -0.5f, yPosition + -0.5f, 0.f, 1.f,
            xPosition + -0.5f,  yPosition + 0.5f, 0.f, 0.f,
            xPosition + 0.5f,  yPosition + 0.5f, 1.f, 0.f,
            xPosition + 0.5f, yPosition + -0.5f, 1.f, 1.f
        };
#ENDCODE

But we would have to send a different vertex buffer to the GPU each time we want to change the position of the Quad. This is inefficient, even more so if your trying to render 100's of sprites for a game, each one with a different vertex buffer every frame! Instead we just specify the origin position in a <b>constant buffer</b> and add it to each local vertex position in the vertex shader. So we can reuse the same vertex buffer for all quads we draw. We can do this for all attributes that are constant across all vertices like color, scale, position and rotation.

#HR

##Contents

#Contents id0 Creating the Constant Buffer
#Contents id1 Writing into the Constant Buffer
#Contents id2 Using our Constant buffer
#Contents id3 Putting our Constant Buffer to use
#Contents id4 Conclusion
#Contents id5 Quiz

#HR

#ID_HEADER id0 Creating the Constant Buffer

As we know, the D3D Device is in charge of create buffers, so we'll be using this to create a contant buffer to fill in the position of our vertices. First we need to declare the data we want to send to the shader. We do this by defining a <i>struct</i>.  

#CODE
// Create Constant Buffer
struct Constants
{
    float2 pos;
    float2 paddingUnused; // color (below) needs to be 16-byte aligned! 
    float4 color;
};
#ENDCODE

We're going to want to declare the types <i>float2</i> and <i>float4</i> aswell. 

#CODE
//in a file called 3DMaths.h
struct float2
{
    float x, y;
};

struct float4
{
    float x, y, z, w;
}; 

#ENDCODE	

and include this file at the top of our main.cpp file:

#CODE
#include <windows.h>

#include "3DMaths.h"
#ENDCODE

You'll also notice padding in our constant buffer struct. Values in the constant buffer can't cross a 16 byte boundary. So when we declare the position above the color in our struct, since color is 16bytes big, if it doesn't start on a 16byte boundary it will cross one, making it inaccesible in the shader. So we pad it out so color starts on a 16 byte boundary. We could also put position after color without padding and that would work. 

#CODE 
//NOTE: Different way of declaring the struct to avoid padding
struct Constants
{
    float4 color;
    float2 pos;
};

We're then going to create the buffer on the GPU which will store these values for us.

#CODE
ID3D11Buffer* constantBuffer;

{
    D3D11_BUFFER_DESC constantBufferDesc = {};

    // ByteWidth must be a multiple of 16, per the docs
    constantBufferDesc.ByteWidth      = sizeof(Constants) + 0xf & 0xfffffff0;
    constantBufferDesc.Usage          = D3D11_USAGE_DYNAMIC;
    constantBufferDesc.BindFlags      = D3D11_BIND_CONSTANT_BUFFER;
    constantBufferDesc.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;

    HRESULT hResult = d3d11Device->CreateBuffer(&constantBufferDesc, nullptr, &constantBuffer);
    assert(SUCCEEDED(hResult));
}

#ENDCODE

Here we're declaring the size of the buffer we need. In this case the size of the Constants struct. Since it needs to be a multiple of 16, we round the size to the nearest multiple of 16. 

We're going to be changing the values in this buffer per frame, so we want to use the <i>D3D11_USAGE_DYNAMIC</i> flag. We're also going to be writing into it from the CPU side so we pass the <i>D3D11_CPU_ACCESS_WRITE</i>

#HR


#ID_HEADER id1 Writing into the Constant Buffer

Next step is to now write into our buffer. Each frame we're going to map the buffer, that is get a pointer to the buffer into video memory. We can then cast the memory as the struct we said it was. Something to note here is we're using the <i>D3D11_MAP_WRITE_DISCARD</i> flag. This means we don't have to worry about writing over a previous constant buffer that may be still in use by the GPU from a previous draw call. It will create a new buffer for us so we don't have to manage this.  

#CODE 
D3D11_MAPPED_SUBRESOURCE mappedSubresource;
d3d11DeviceContext->Map(constantBuffer, 0, D3D11_MAP_WRITE_DISCARD, 0, &mappedSubresource);
Constants* constants = (Constants*)(mappedSubresource.pData);
constants->pos = {0.25f, 0.3f};
constants->color = {1.0f, 0, 0, 1.f};
d3d11DeviceContext->Unmap(constantBuffer, 0);
#ENDCODE

We get the pointer to the buffer, set the position and color then <i>Unmap</i> the buffer to say we're finished with it. 

#HR

#ID_HEADER id2 Using our Constant buffer

To use our constant buffer now, we have to do two things. 
1. We have to define it in our shader. 
2. We have to attach our constant buffer to the right shader slot.

So first we'll define it in our shader. It looks like this:

#CODE
cbuffer constants : register(b0)
{
    float2 offset;
    float4 uniformColor;
};
#ENDCODE

We're defining it in our shader to mirror the struct in our game code. You'll notice though we don't have to add the extra padding to be 16 byte aligned like we did on the CPU side. This is because the shader will implicitly do this for us. <a href='https://docs.microsoft.com/en-au/windows/win32/direct3dhlsl/dx-graphics-hlsl-packing-rules?redirectedfrom=MSDN'>You can read more about it here</a>. We use the the register <i>b0</i> to identify it which we will reference in our CPU code. The letter b here is for constant buffer. <a href="https://docs.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl-variable-register">You can see other letters here</a>(we've already seen the letter s and t being used in the previous lesson).

Now that we've declared it in our shader, we can attach our constant buffer to it in our game loop. We do this via the following:

#CODE
d3d11DeviceContext->VSSetConstantBuffers(0, 1, &constantBuffer);
#ENDCODE


Before we draw the quad we set the constant buffer. The first argument is the register index we set in the shader - for us this was 0. The second argument is the number of buffers we're setting - only 1, and a pointer to our constant buffer. <a href="https://docs.microsoft.com/en-us/windows/win32/api/d3d11/nf-d3d11-id3d11devicecontext-vssetconstantbuffers">You can read more here</a>.

#HR

#ID_HEADER id3 Putting our Constant Buffer to use

The last step in this tutorial is actually using the data given to us in the shader. We can offset the quad's position each frame, and we can change it's color. Let's do that. 

Our vertex shader will look like this: 

#CODE

VS_Output vs_main(float2 pos : POS)
{
    VS_Output output;
    output.pos = float4(pos + offset, 0.0f, 1.0f);
    output.color = uniformColor;
    return output;
}

#ENDCODE

The same vertex shader as last time but now we can use the variables <i>offset</i> and <i>uniformColor</i> from our constant buffer. We're offseting the x position and changing the quads color. We also have to pass the color value from the vertex shader to the pixel shader since the pixel shader can't access the constant buffer.

#ID_HEADER id4 Conclusion

Phew! Made it through another lesson. Got constant buffers down which is one more step to understanding D3D. In this lesson we ,  and . 

1. Created a constant buffer struct to store a position and color.
2. created a buffer on the GPU to store this struct.
3. Got a pointer to the values values and updated then each game loop using Map and UnMap functions.
4. Binded the buffer to the GPU when we wanted to use it.
5. We defined our constant buffer in our shader, making sure we match the layout of it to our struct on the CPU side.
6. We used the actual data in our vertex shader to update the position of the vertex and sent the color to the pixel shader.

#ANCHOR https://github.com/Olster1/directX11_tutorial/tree/main/lesson5 You can see the full code for this article here

#HR

#Email

#HR

#ID_HEADER id5 Quiz

<b>1. Why do we need padding in our constant buffer struct on the CPU side?</b>
[Because values can't cross 16byte alignment boundaries]
<b>2. Why do we use the D3D11_MAP_WRITE_DISCARD flag when mapping our buffer? </b>
[When we draw the Quad, the GPU could be multiple frames behind the CPU. Therefore the values in the constant buffer from the frame we are drawing need to be preserved, not overwritten. So by using D3D11_MAP_WRITE_DISCARD, it tells D3D to create a new buffer in memory for us to store the values in without overriding ones that are still needed by the GPU.]
<b>3. Can you access constant buffer variables in the pixel shader? </b>
[No if you have used VSSetConstantBuffers to update your constant buffer, you have to access them in the vertex shader and send them to the pixel shader via VS_OUTPUT struct. However if you use the function PSSetConstantBuffers, you can access them in the pixel shader and not in the vertex shader.]
<b>4. Can you send more than one constant buffer at a time using <i>VSSetConstantBuffers</i>?</b>
[Yes, you can pass an array to this function and set the number of buffers, each one attaching to the subsequent slot ids based off the first slot index.]

#HR

#INTERNAL_ANCHOR_IMPORTANT ./direct3d_11_part4.html PREVIOUS LESSON
#INTERNAL_ANCHOR_IMPORTANT ./direct3d_11_part6.html NEXT LESSON