CMD:beanbullets(playerid, params[])
{
    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT || !IsPlayerSpawned(playerid))
        return SendErrorMessage(playerid, "You can't use this command right now.");

    if(GetFactionType(playerid) != FACTION_POLICE)
        return SendErrorMessage(playerid, "You must be a police officer.");

    if(!IsPlayerDuty(playerid))
        return SendErrorMessage(playerid, "You must on duty to use bean bullets.");
    
    if(GetPlayerWeapon(playerid) != WEAPON_SHOTGUN)
        return SendErrorMessage(playerid, "You need to carry a shotgun to use this!");

    if(!PlayerData[playerid][pBeanBullets])
    {
        PlayerData[playerid][pBeanBullets] = 1;
        SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s takes out a bean bullets as he reload it into their shotgun.", ReturnName(playerid, 0));
    }
    else
    {
        PlayerData[playerid][pBeanBullets] = 0;
        SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s removes bean bullets as he reload it and change into normal bullets.", ReturnName(playerid, 0));
    }
    return 1;
}

CMD:tazer(playerid, params[])
{
    if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT || !IsPlayerSpawned(playerid))
        return SendErrorMessage(playerid, "You can't use this command right now.");

    if(GetFactionType(playerid) != FACTION_POLICE)
        return SendErrorMessage(playerid, "You must be a police officer.");

    if(!IsPlayerDuty(playerid))
        return SendErrorMessage(playerid, "You must on duty to use tazer.");

    if(!PlayerData[playerid][pTazer])
    {
        PlayerData[playerid][pTazer] = 1;
        GivePlayerWeapon(playerid, 23, 20000);
        SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s takes out a tazer from their holster.", ReturnName(playerid, 0));
    }
    else
    {
        PlayerData[playerid][pTazer] = 0;
        SendNearbyMessage(playerid, 15.0, X11_PLUM, "** %s puts their tazer into their holster.", ReturnName(playerid, 0));
    }
    return 1;
}