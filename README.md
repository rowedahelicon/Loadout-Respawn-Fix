# TF2---Loadout-Respawn-Fix
A quick attempt at fixing an exploit(?) with the load_itempreset command

This is a lame attempt, but it works, it would probably be more efficient to patch the memory for this function.

The inspiration for this comes from this discussion, https://forums.alliedmods.net/showpost.php?p=2777610&postcount=5.

Sure enough, forcing the boolean value to true in the `PointInRespawnRoom` function called in `CTFPlayer::CheckInstantLoadoutRespawn` will ensure that a player must be on the team of a respawn room they are inside or touching. 

This is meant to fix an issue that occurs on certain maps where an enemy player can "touch" the resupply room, which allows them to run the command and instantly respawn in their own spawnroom. This is done to spawncamp usually.

As an additional note, I also tried using the `m_iSpawnRoomTouchCount`as a way to determine if a player is in their spawnroom or not but that too isn't checked for team ownership correctly.

# This requires dhooks

Credit for this goes to **nosoop** and **Psyk0tik**, I just wrote out code for it.
