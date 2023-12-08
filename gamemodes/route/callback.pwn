#if defined INITIALIZE_WITH_FOR
hook OnPlayerConnect(playerid)
{
	for(new i; i < MAX_DOTS; i++)
	{
		Routes[playerid][i] = -1;	
	}
	return Y_HOOKS_CONTINUE_RETURN_1;
}
#endif

hook OnPlayerDisconnect(playerid, reason)
{
	if(playerHasGPSActive[playerid]) 
	{
		ForcePlayerEndLastRoute(playerid);
	}
	return Y_HOOKS_CONTINUE_RETURN_1;
}

#if defined GPS_MODE_1
/*
hook OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
	StartPlayerPath(playerid, fX, fY, fZ);
	return Y_HOOKS_CONTINUE_RETURN_1;
}*/

#endif

hook OnPlayerStateChange(playerid, newstate, oldstate)
{
    if(oldstate == PLAYER_STATE_DRIVER)
    {    
        if(IsPlayerGPSIsActive(playerid))
        {
            HideGPSRoutes(playerid);
        }
    }
    if(newstate == PLAYER_STATE_DRIVER)
    {
		if(IsPlayerGPSIsActive(playerid))
		{
			RestorePlayerGPSRoutes(playerid);
		}
    }
    return 1;
}