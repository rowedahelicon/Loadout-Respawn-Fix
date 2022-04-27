#pragma semicolon 1
#pragma newdecls required

#include <dhooks>

Handle hDetourRespawn = INVALID_HANDLE;
Handle hCheckRespawn = INVALID_HANDLE;

public Plugin myinfo = 
{
    name = "Block Instant Respawn",
    author = "Rowedahelicon (code) / Psyk0tik + nosoop",
    description = "Provides a way to block instant respawns from the load_itempreset command.",
    version = "1.0",
    url = "https://forums.alliedmods.net/showthread.php?p=2770618#post2770618"
}

public void OnPluginStart()
{
    Handle hGameData = LoadGameConfigFile("respawn");

    if(!hGameData)
        SetFailState("Can't find respawn gamedata.");

    hDetourRespawn = DHookCreateDetour(Address_Null, CallConv_THISCALL, ReturnType_Void, ThisPointer_CBaseEntity);

    if (!hDetourRespawn)
        SetFailState("Couldn't setup respawn detour");

    if (!DHookSetFromConf(hDetourRespawn, hGameData, SDKConf_Signature, "CTFPlayer::CheckInstantLoadoutRespawn"))
        SetFailState("Failed to load CTFPlayer::CheckInstantLoadoutRespawn signature from gamedata");

    DHookAddParam(hDetourRespawn, HookParamType_Int);

    if (!DHookEnableDetour(hDetourRespawn, false, Detour_OnLoadoutRespawn)) //Post
        SetFailState("Failed to detour CTFPlayer::CheckInstantLoadoutRespawn.");

    StartPrepSDKCall(SDKCall_Static);
    if (!PrepSDKCall_SetFromConf(hGameData, SDKConf_Signature, "PointInRespawnRoom"))
    {
        SetFailState("Failed to prep PointInRespawnRoom");
    }
    PrepSDKCall_AddParameter(SDKType_CBasePlayer, SDKPass_Pointer);
    PrepSDKCall_AddParameter(SDKType_Vector, SDKPass_ByRef);
    PrepSDKCall_AddParameter(SDKType_Bool, SDKPass_Plain);
    PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
    hCheckRespawn = EndPrepSDKCall();
}

public MRESReturn Detour_OnLoadoutRespawn(int client, Handle hParams)
{ 
    if(!IsValidClient(client)) return MRES_Ignored;

    float vecOrigin[3];
    GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", vecOrigin);

    bool inSpawn = SDKCall(hCheckRespawn, client, vecOrigin, true);

    if(inSpawn)
    {
        return MRES_Ignored;
    }
    else
    {
        return MRES_Supercede;
    }
}

stock bool IsValidClient(int iClient) 
{
    return (iClient > 0 && iClient <= MaxClients);
}
