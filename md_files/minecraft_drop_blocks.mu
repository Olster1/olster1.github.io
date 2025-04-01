#CARD
##Drop Blocks

In minecraft when you mine a block, it drops the block to pick up. These blocks have to respond to what blocks are around them: if you put a block ontop of them, they have to move out of the way. They also have to fall with gravity.

I thought about how to solve this and went about the easiest and simplest solution. Each update loop the pickup block checks if it's inside a block, it it is, find the closest free block around it. I only check a 3 x 3 x 3 square i.e. one block from the block they're on. If no free block is found, just try to move upward. In code it looks like this: 

#CODE 
float3 findClosestFreePosition(GameState *gameState, float3 startP, float3 defaultDir) {
    float3 result = defaultDir;
    float closestDist = FLT_MAX;
    float3 startP_block = convertRealWorldToBlockCoords(startP);
    bool found = false;

for(int z = -1; z <= 1; z++) {
        for(int y = -1; y <= 1; y++) {
            for(int x = -1; x <= 1; x++) {
                if(x == 0 && y == 0 && z == 0) {
                    //NOTE: Don't test the block we're in
                    continue;
                } else {
       
        float3 offset = make_float3(x, y, z);

        float3 blockP = plus_float3(offset, startP_block);

        BlockChunkPartner blockPtr = blockExists(gameState, blockP.x, blockP.y, blockP.z, BLOCK_EXISTS_COLLISION);
        if(!blockPtr.block) {
            float3 dirVector = minus_float3(blockP, startP);
            float d = float3_magnitude_sqr(dirVector);

            if(d < closestDist) {
                result = dirVector;
                closestDist = d;
                found = true;
            }
        }
                }
            }
        }
    }
    
    return result;
}
#ENDCODE

#HR

###Entity Update 
Now that we have 'findClosestFreePosition' we can use it in the pickup block update function.

#CODE 
void updatePickupBlock() {
    float3 accelForFrame = make_float3(0, 0, 0);

//NOTE: Convert the floating point position to which block it is inside
                float3 worldP = convertRealWorldToBlockCoords(e->T.pos);

                if(blockExistsReadOnly(gameState, worldP.x, worldP.y, worldP.z, BLOCK_EXISTS_COLLISION)) {
                    //NOTE: Pickup block is inside another block so moveout of the way
                    float3 moveDir = findClosestFreePosition(gameState, e->T.pos, make_float3(0, 1, 0), gameState->searchOffsets, arrayCount(gameState->searchOffsets), arrayCount(gameState->searchOffsets));
                    moveDir = normalize_float3(moveDir);
                    e->dP = make_float3(0, 0, 0);
                    accelForFrame = plus_float3(accelForFrame, scale_float3(100.0f, moveDir));
                    
                    //NOTE: DEBUG code to place a red block if we are colliding. This is a helpful debug aid
                    pushAlphaCube(gameState->renderer, worldP, BLOCK_CLOUD, make_float4(1, 0, 0, 1.0f));
                } else if(!blockExistsReadOnly(gameState, worldP.x, worldP.y -1 , worldP.z, BLOCK_EXISTS_COLLISION)) {
                    //NOTE: check if should apply gravity
                    accelForFrame.y = -10;
                }

                 //NOTE: Integrate acceleration
        e->dP = plus_float3(e->dP, scale_float3(gameState->dt, accelForFrame)); //NOTE: Already * by dt 
        //NOTE: Apply drag
        e->dP = scale_float3(0.95f, e->dP);
        //NOTE: Integrate velocity
        e->T.pos = plus_float3(e->T.pos, scale_float3(gameState->dt, e->dP));
}
#ENDCODE
#HTML
<video controls="controls" width="800" height="600" type="video/webm" name="Drop Blocks">
  <source src="./images/dropBlocks.webm">
</video>
#ENDHTML

#ANCHOR_IMPORTANT https://github.com/Olster1/minecraft_clone You can see the codebase here