function IsPlayerDeveloper(playerid)
{
    if(AccountData[playerid][uDeveloper] == DEVELOPER_GAMEMODE){
        return DEVELOPER_GAMEMODE;
    }
    else if(AccountData[playerid][uDeveloper] == DEVELOPER_CLIENT){
        return DEVELOPER_CLIENT;
    }
    return 0;
}