#CARD
##Collision for attacking enemies
###25th September 2024

So far in my 2d top down game I've created a player and enemy entities. I'm now finishing the attack between them. This involves: working out when there's a collision between them, playing the correct animation, dealing damage & knocking them back from the attack. The hardest out of these is working out the collision between them.

The simplest method is to have an box around them, and if they overlap we should do something. I've separated the game engine into two parts: collision & physics update & the entity gameplay update. This is so we can do frame independent physics easily & by coupling collision detection with the physics update, we avoid the problem of tunnelling - that is an entity passes through another but each frame occurs either side of it, so we never detect a collision. 

The downside to doing it this way is that we're storing all collision events prior to using them instead of just acting on the collision straight away (retained mode vs immediate mode response) which adds memory usage.  But we also get tracking of the state of the collision event: is it Enter, Stay or an Exit event? Which can be handy for writing gameplay code. 

I'll keep it as it is until I reach a point where it no longer works: either gameplay wise or performance wise. 

Once we have processed the collision, the rest is easy. In the update entity function, we check if there was an enter or stay collision by an enemy on the player and the enemy is attacking (if the enemy was just wandering or hurt itself, we don't want to penaltise the player). If this check idms true, reduce health, play the hurt animation, and add an impulse force to the player to give some feedback to the player. 


#CODE
updateEntity(Entity *e) {
    if(e->type == ENTITY_PLAYER) {
        Collider c = e->colliders[HIT_COLLIDER_INDEX];

        //NOTE: Check if anything hit this collider
        if(c.collideEventsCount > 0) {
            //NOTE: Loop through all the collision events
            for(int i = 0; i < c.collideEventsCount; ++i) {
                const CollideEvent event = c.events[i];  

                if((event.type == COLLIDE_STAY || event.type == COLLIDE_ENTER) && event.entityType == ENTITY_ENEMY && event.damage > 0) {
                    //NOTE: Hit by enemy - decrement health
                    e->health -= event.damage;
                    
                    //NOTE: Apply knockback impulse to give feedback to player 
                    e->velocity.xy = plus_float2(e->velocity.xy, scale_float2(hitForce, event.hitDir));
                }
            }
        }
    }
    ...
}
#ENDCODE

An entity can have multiple colliders on it for different purposes. In this case the player has a collider in the slot 'HIT_COLLIDER_INDEX' that's been designated for the hurt box. To know whether an enemy is actually attacking, we check whether the collider event contains damage to apply to the player.

#HTML
<video controls="controls" width="800" height="600" type="video/webm" name="attack bat">
  <source src="./images/attack_bat.webm">
</video>
#ENDHTML

#ANCHOR_IMPORTANT https://github.com/Olster1/adventure_game You can see the codebase here


