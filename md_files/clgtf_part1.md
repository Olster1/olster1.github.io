#CARD
#TITLE Using clgtf library for 3d graphics
##Including the library
#HR
#CARD
#ANCHOR_IMPORTANT https://github.com/jkuhlmann/cgltf You can get the cgltf.h file here

In these articles, I’m going to walk through loading and animating 3d models using the library cgltf. There are other libraries that are often used for 3d models - assimp & tinygltf being cited commonly. The advantage cgltf has over other libraries is that it's simple to incorporate into your project and has a small footprint, as it's written in C99. It's also written in the 'single file header' library style pioneered by Sean Barret, which adds to the ease. 

The other thing to consider is that cgltf only loads .gltf files, whereas assimp can load 40+ different formats.  This isn't necessarily a bad thing. .gltf files are an open standard developed by the Khronos Group and support everything you'd need from a 3d format - skeletal animation, texture mapping, normal mapping etc. You can also convert other proprietary formats like .fbx to .gltf files. 

#HR

To start with we're going to include the header file into the project. In a new file called animation.cpp, add this code:

#CODE
#define CGLTF_IMPLEMENTATION
#include "./cgltf.h" //NOTE: Location of the cgltf file
#ENDCODE

That's it! you should be able to compile as normal with zero fuss. That's the power of single header files writtern in C99. 

#HR

Next we're going to load a .gltf file. To do this we're going to use the function cgltf_parse_file. We'll put it inside 

#CODE
void loadGltfFile(char *fileName) {
    cgltf_options options = {};
    cgltf_data* data = NULL;
    cgltf_result result = cgltf_parse_file(&options, fileName, &data);
}
#ENDCODE

