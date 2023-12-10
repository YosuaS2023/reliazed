ReturnName2(playerid, underscore=1)
{
    static
        name[MAX_PLAYER_NAME + 1];

    GetPlayerName(playerid, name, sizeof(name));

    if(!underscore) {
        for (new i = 0, len = strlen(name); i < len; i ++) {
            if(name[i] == '_') name[i] = ' ';
        }
    }
    return name;
}

Float:GetHealth(playerid)
{
    return PlayerData[playerid][pHealth]; 
}
Float:GetArmour(playerid)
{
    return PlayerData[playerid][pArmorStatus]; 
}

stock SetArmour(playerid, Float:armour)
{
    PlayerData[playerid][pArmorStatus] = armour;

    if(PlayerData[playerid][pArmorStatus] > 100)
        PlayerData[playerid][pArmorStatus] = 100;

    else if(PlayerData[playerid][pArmorStatus] <= 0)
        PlayerData[playerid][pArmorStatus] = 0;

    SetPlayerArmour(playerid, PlayerData[playerid][pArmorStatus]);
    return 1;
}

SetPlayerRate(playerid, Float:rate)
{
    PlayerData[playerid][pDead] = rate;

    if(PlayerData[playerid][pDead] > 100)
    {
        PlayerData[playerid][pDead] = 100;
    }
    else if(PlayerData[playerid][pDead] < 0)
    {
        PlayerData[playerid][pDead] = 0;
    }
    return 1;
}

// weapon
PlayerHasBeanBullets(playerid)
{
    return (GetPlayerWeapon(playerid) == WEAPON_SHOTGUN && PlayerData[playerid][pBeanBullets]);
}
PlayerHasTazer(playerid)
{
    return (GetPlayerWeapon(playerid) == WEAPON_SILENCED && PlayerData[playerid][pTazer]);
}
