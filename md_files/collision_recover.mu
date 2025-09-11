#CARD
##Collision Recovery

For the player collision detection with the world, we use a raycast against all the blocks in a certain radius of the player. We then find the shortest distance to a block and move that far. This works quite well but every now and then the player would get stuck in a block and wouldn't be able to get out. I'm not sure exactly what caused this but assume it is just a certain angle and block arrangement that causes the player to move inside a block slightly. This is a common collision detection thing to do: try as hard as possible to not get stuck in something, but if you do have someway to recover from it. I originally thought of the GJK/EPA algorithm. But instead could just do a really simple thing, search for the closest empty block space, just like we did for the pickup blocks. 

To do this we just check in a 3 x 3 x 3 cube around us whether there is a block present. We loop through all positions and pick the closest empty position. If there isn't anyone, we just default to head upwards.

#CODE
float3 findClosestFreePosition(GameState *gameState, float3 startP, float3 defaultDir, float3 *searchOffsets, int searchOffsetCount) {
    float3 result = defaultDir;
    float closestDist = FLT_MAX;
    float3 startP_block = convertRealWorldToBlockCoords(startP);
    bool found = false;

    for(int i = 0; i < searchOffsetCount; ++i) {
        float3 offset = searchOffsets[i];

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
    
    return result;
}
#ENDCODE

In our player movement code we call this function if we're stuck in a block.

#CODE
... other player movement code

if(shortestNormalVector.x == 0 && shortestNormalVector.y == 0 && shortestNormalVector.z == 0) {
    //NOTE: Inside the block
    float3 moveDir = findClosestFreePosition(gameState, e->T.pos, make_float3(0, 1, 0), gameState->searchOffsets, arrayCount(gameState->searchOffsets), arrayCount(gameState->searchOffsets));
    moveDir = normalize_float3(moveDir);
    e->recoverDP = plus_float3(e->recoverDP, scale_float3(1.0f, moveDir));
} else {
    //NOTE: Not in a block so reset the recover dP
    e->recoverDP = make_float3(0, 0, 0);
}   

...
#ENDCODE

The recoverDP is a seperate field than the dP used by gravity and such. This is becuase it doesn't get dampened when we run into something i.e. the inside walls of a block. It affects the player no matter what. 
We integrate this recover DP to get a delta position each frame, and add it to the total player position.

#CODE 
void updateRecoverMovement(GameState *gameState, Entity *e) {
    //NOTE: Apply drag
    e->recoverDP = scale_float3(0.95f, e->recoverDP);

    //NOTE:Integrate velocity
    e->T.pos = plus_float3(e->T.pos, scale_float3(gameState->dt, e->recoverDP));

}
#ENDCODE

To test this now we need a way to purposely run inside a block. I was trying to get the bug to repeat but they were few and far between. So this gives a easily testable scenario. To do this we toggle into camera mode, which allows us to fly around with no collision. Once inside a block we revert to player mode and see what happens.


#HTML
<video controls="controls" width="800" height="600" type="video/webm" name="attack bat">
  <source src="./images/collision_recover.webm">
</video>
#ENDHTML

#ANCHOR_IMPORTANT https://github.com/Olster1/minecraft_clone You can see the codebase here


