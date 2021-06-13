#CARD
#TITLE OpenGL and Direct3D Perspective Matrix
##Perspective Matrix Four Ways

#CARD

#HR

The Perspective Matrix is vital to 3d graphics. It's the final matrix responisble for projecting a 3d object from the world onto a flat screen. Unlike the other two common matrices used in 3d graphics: the Model Matrix (resposible for moving the vertices from Model to World Space) and View Matrix (responsible for moving the vertices from World to Camera Space), the perspective matrix can be hard to intuitively understand. Specifically the the Z-Axis transofrmation to prepare it correctly for the z-divide.

Adding to this is the different orientations of the axis used in the 3d game world. There are two common orientations - the so called left hand and right hand coorindate orientations. The positive X axis pointing right, the positive Y axis pointing up but the positive Z-axis pointing into the screen (Left handed) or the positive Z-axis pointing out of the screen (Right Handed coordinate system). Although these are the two most common coordinate systems there are 4 possible unique 3d orientations that a game world could use. This means 4 different perspective matrices to map the game world onto a flat screen. This is only for one graphics API. The number of matrices increase by the number of graphics API's with their own internal coordinate systems (NDC space) that you have to convert to.

In OpenGL NDC space, the coordinate system is Left-Handed (the z axis pointing into the screen). Direct3D is the same, but the Z-Axis origin is in a different place. In Opengl the Z-Axis ranges from -1 to 1, in Direct3D the Z-Axis ranges from 0 to 1 (both pointing into the screen). 

On top of this, there is one more thing to take into consideration that also affects the perspective matrix: the way the matrix multiplication function is defined in the GPU shader language. How the shader language expects the matrix to be laid out in memory: Row Major or Colum Major. 

#HR

##Contents

#Contents id0 Three factors we have to take into account
#Contents id1 4x4 Matrix Struct defined in code
#Contents id2 Same Code for all the Perspective Matrices
#Contents id3 Matrix 1
#Contents id4 Matrix 2
#Contents id5 Matrix 3
#Contents id6 Matrix 4
#Contents id7 Orthographic Matrices
#Contents id8 Same Code for all the Orthographic Matrices
#Contents id9 Matrix 5
#Contents id10 Change the X Y origin of window 
#Contents id11 Matrix 6
#Contents id12 Matrix 7
#Contents id13 Matrix 8
#Contents id15 Notes

#HR

#ID_HEADER id0 Three factors we have to take into account

So there are three factors that contribute to the possible perspective matrices you could have: 

1. The coordinate system orientation of the Game World.

2. The coordinate system of the GPU API your're using (NDC Space)

3. The way the GPU API interprets the memory layout of the matrix in the shader language (is is Row Major or Column Major?). 

So to build the right perspective matrix, you have to be aware of all three of these things. For simplicity I'll only be looking at left and right handed game world coordinate systems (the two most common ones) and the two graphics APIs: OpenGL and Direct3D. I won't be deriving the matrix, just showing you the matrix and how you'd define it in code so you can see the differences. 

#HR 

#ID_HEADER id1 4x4 Matrix Struct defined in code 

Our matrix struct will look like this: 

#CODE

struct Matrix_4x4 {
    float E[16];
};
#ENDCODE

Just 16 floats side by side in memory. Our job is to fill the right values in. 

#HR

#ID_HEADER id2 Same Code for all the Perspective Matrices

All the perspective matrices will be using the same data to build the matrix. 

#CODE

//NOTE: The Field of View the camera can see in degrees
float FOV_degrees = 60.0f;

//NOTE: Our Near and Far plane constants
float nearClip = 0.1f;
float farClip = 1000.0f;

//NOTE: Convert the Camera's Field of View from Degress to Radians
float FOV_radians = (FOV_degrees*PI32) / 180.0f;

//NOTE: Get the size of the plane the game world will be projected on.
float t = tan(FOV_radians/2); //plane's height
float r = t*aspectRatio; //plane's width

#ENDCODE

We have the Near and Far clip plane constants that may be something like 0.1 and 1000 respectively. This defines the min and max bounds of what is visible on the Z-Axis.

We then have the Field of View (FOV) of the camera in the game world. It is how much of the world in the X and Y axis the camera can see at once. We convert it to radians. 

We divide the FOV by 2 since the FOV is the angle for the whole camera view (the whole viewport) but we just want half since the x,y origin is in the middle of the screen. The FOV is assumed for what the camera can see in the Y-Axis. We use the aspect ratio of the viewport to get the size of the projection plane in the X-Axis. (You could just as easily have the field of view be defined as what the X-Axis can see and use the aspect ratio to get the Y-Axis size).

#IMPORTANT The near and clip plane <b>aren't</b> negated based on the whether the game axis orientation is left handed or right handed. <b>They are always positive.</b>  

#HR

#ID_HEADER id3 Matrix 1: OpenGL for Left Handed Orientated Game World (Camera looking down the Positive Z-Axis)

#CODE

Matrix_4x4 result = {{
        1 / r,  0,  0,  0,
        0,  1 / t,  0,  0,
        0,  0,  (farClip + nearClip)/(farClip - nearClip),  1, 
        0, 0,  (-2*nearClip*farClip)/(farClip - nearClip),  0
    }};

#ENDCODE

You'll notice it has the 1 in the 4th column, 3rd row which allows for the divide by Z the graphics card will do for us that makes the world have perspective (as opposed to orthographic). The 1 is positive since the Z-Axis in the game world is the same direction as the Z-Axis in OpenGl's NDC space (positive Z going into the screen).

The values are also loaded into memory so that they are interleaved like so (moving left to right, top to down):

#CODE

XAxis.x XAxis.y XAxis.z XAxis.w YAxis.x YAxis.y YAxis.z YAxis.w 
ZAxis.x ZAxis.y ZAxis.z ZAxis.w WAxis.x WAxis.y WAxis.z WAxis.w

#ENDCODE

This is how the Opengl shader langauge expects the memory to be laid out for it's matrix multiplication. 

#HR

#ID_HEADER id4 Matrix 2: OpenGL for Right Handed Orientated Game World (Camera looking down the Negative Z-Axis)


#CODE

Matrix_4x4 result = {{
        1 / r,  0,  0,  0,
        0,  1 / t,  0,  0,
        0,  0,  -((farClip + nearClip)/(farClip - nearClip)),  -1, 
        0, 0,  (-2*nearClip*farClip)/(farClip - nearClip),  0
    }};

#ENDCODE

You'll notice the 1 value in the 4th column, 3rd row is now negative. Also the Z-component of the matrix (3rd Column, 3rd Row) is also negative now too. This is in order to flip the Z-Axis. You can't just have the z-component (3rd Column, 3rd Row) negative since then the homogenous value of the resulting vector (w component) would be neagtive and we would divide the X and Y by a negative value, flipping them aswell. So we want to the 1 value in the 4th column, 3rd row to also be negative.

 #HR

#ID_HEADER id5 Matrix 3: Direct3D for Left Handed Orientated Game World (Camera looking down the Positive Z-Axis)

#CODE

Matrix_4x4 result = {{
        1 / r,  0,  0,  0,
        0,  1 / t,  0,  0,
        0,  0,  farClip/(farClip - nearClip),  (-nearClip*farClip)/(farClip - nearClip), 
        0, 0,  1,  0
    }};

#ENDCODE

For the Direct3D matrices we have to account for two things: the memory layout of the matrix is swapped to what is used with Opengl: it is the transpose of the OpenGL matrix. Also the origin of the Z-Axis in NDC space is at zero not negative one. 

To account for the memory layout, you'll see the matrix is the transpose of the OpenGL one: the perspective value of <b>1</b> is in 3rd column, 4th row now. And to account for the NDC origin, we no longer multiply the Z-Translation component(3rd Row, 4th Column) by 2 and the Z-Component(3rd Row, 3rd Column) value has also changed.

The memory layout the Direct3D expects (moving left to right, top to down):

#CODE

XAxis.x YAxis.x ZAxis.x WAxis.x XAxis.y YAxis.y ZAxis.y WAxis.y
XAxis.z YAxis.z ZAxis.z WAxis.z XAxis.w YAxis.w ZAxis.w WAxis.w

#ENDCODE

 #HR

#ID_HEADER id6 Matrix 4: Direct3D for Right Handed Orientated Game World (Camera looking down the Negative Z-Axis)

#CODE

Matrix_4x4 result = {{
        1 / r,  0,  0,  0,
        0,  1 / t,  0,  0,
        0,  0,  -farClip/(farClip - nearClip), (-nearClip*farClip)/(farClip - nearClip), 
        0, 0,  -1,  0
    }};

#ENDCODE

We've now added in the negative values to flip the positive Z-axis from pointing out of the screen to into the screen (Same as what we did with the OpenGL matrix).

#HR

That's it. The four most common perspective matrices you'll come across in game programming. It should be noted that these matrices assume the <i>near clip plane</i> is also the distance of the projection plane from the camera's eye. This doesn't have to be the case: the distance of the plane can be decoupled from the <i>near clip plane</i>, although this is less common and doesn't hold any significant advantages.

#HR

#ID_HEADER id7 Orthographic Matrices

Above are all perspective matrices where all the light rays are coming into a single point: the centre of the camera. The other type of matrix you'll come across in graphics programming is the <b>Orthographic Matrix</b> where all the light rays hiting the camera are parallel to each other . This is handy for doing GUI programming, game UI or making a program like a text editor that doesn't need perspective. Just like there are 4 perspective matrices to account for the two game world orientations and two Graphics APIs, there are also 4 Orthographics matrices for the same cases. I'll outline them now.

#HR

#ID_HEADER  id8 Same Code for all the Orthographic Matrices

#CODE
//NOTE: The size of the plane we're projection onto
float a = 2.0f / screenWidth; 
float b = 2.0f / screenHeight;

//NOTE: Near and Far Clip plane
float nearClip = 0.1f;
float farClip = 1000.0f;

//NOTE: We can offset the origin of the viewport by adding these to the translation part of the matrix
float originOffsetX = 0; //NOTE: Defined in NDC space
float originOffsetY = 0; //NOTE: Defined in NDC space

#ENDCODE

#IMPORTANT The near and clip plane <b>aren't</b> negated based on the whether the left handed or right handed coordinate system is being used. <b>They are always positive.</b>  

#HR

#ID_HEADER id9 Matrix 5: OpenGL Orthographic Matrix For Left Handed Orientation (Positive Z-Axis into the screen) 

#CODE
    Matrix4 result = {{
            a,  0,  0,  0,
            0,  b,  0,  0,
            0,  0,  (2.0f)/(farClip - nearClip), 0, 
            originOffsetX, originOffsetY, -((farClip + nearClip)/(farClip - nearClip)),  1
        }};
    
#ENDCODE

You'll see the homgenous cooridinate value (4th column, 3rd row) is now zero. Since we don't want to divide by the z-coordinate with a orthographic projection, we want the resulting w coordinate to be a 1. So we put a 1 in the 4th column, 4th row. (If we didn't do this, the w component of the resulting vector would be zero, and the graphics card would try diving the x, y, z values by zero which is not good!).

#HR

#ID_HEADER id10 Change the X Y origin of window 

We also have the ability to change where we want the origin of the incoming vertices to be. This is handy if we want to render as if the bottom-left corner of the window is origin. To do that we would change the origin offset values:

#CODE
    
    //NOTE: Change the origin to the bottom-left corner of our Viewport
    float originOffsetX = -1; //NOTE: Defined in NDC space
    float originOffsetY = -1; //NOTE: Defined in NDC space
#ENDCODE

We could also move the origin of the window to the top-left hand corner which might be handy for text rendering:

#CODE
    
    //NOTE: Change the origin to the top-left corner of our Viewport
    float originOffsetX = -1; //NOTE: Defined in NDC space
    float originOffsetY = 1; //NOTE: Defined in NDC space
#ENDCODE

#HR

#ID_HEADER id11 Matrix 6: OpenGL Orthographic Matrix For Right Handed Orientation (Negative Z-Axis into the screen) 

#CODE
    Matrix4 result = {{
            a,  0,  0,  0,
            0,  b,  0,  0,
            0,  0,  -(2.0f)/(farClip - nearClip), 0, 
            originOffsetX, originOffsetY, -((farClip + nearClip)/(farClip - nearClip)),  1
        }};
    
#ENDCODE

The only difference in this Right Handed Orientation is the negative sign on the Z-component of the matrix (3rd Column, 3rd Row), flipping the incoming z values. We don't have to negate the 1 value in the far right column like in the perspective version, since this time the w component of the resulting vector won't have the incoming z value, it will just stay 1.   

#HR

#ID_HEADER id12 Matrix 7: Direct3D Orthographic Matrix For Left Handed Orientation (Positive Z-Axis into the screen) 

#CODE
    Matrix4 result = {{
            a,  0,  0,  originOffsetX,
            0,  b,  0,  originOffsetY,
            0,  0,  1.0f/(farClip - nearClip), nearClip/(nearClip - farClip)), 
            0, 0, 0,  1
        }};
    
#ENDCODE

We account for the origin shift in Direct3D and the memory layout difference. 

#HR

#ID_HEADER id13 Matrix 8: Direct3D Orthographic Matrix For Right Handed Orientation (Negative Z-Axis into the screen) 

#CODE
    Matrix4 result = {{
            a,  0,  0,  originOffsetX,
            0,  b,  0,  originOffsetY,
            0,  0,  -1.0f/(farClip - nearClip), nearClip/(nearClip - farClip)), 
            0, 0, 0,  1
        }};
    
#ENDCODE

Same as above but we flip the incoming z values. 

#HR

#ID_HEADER id14 Conclusion 

Hopefully this wil be a handy reference when implementing the perspective matrix in your program. We covered the four most common perspective matrices you'll come across aswell as showing the orthographic versions. 

#HR

#ID_HEADER id15 Notes

[1] These matrices and information is taken from <i>3D Math Primer for Graphics and Game Development (2nd Edition) by Fletcher Dunn and Ian Parberry</i> in Chapter 10

[2] <a href='https://www.scratchapixel.com/lessons/3d-basic-rendering/perspective-and-orthographic-projection-matrix/building-basic-perspective-projection-matrix'>You can see the derivation of the perspective matrix here</a>. This is building a matrix like Matrix 4 in the article.



 





