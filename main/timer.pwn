ClearPlayerChat(playerid, line)
{
    for (new i = 0; i < line; i ++) {
        SendClientMessage(playerid, -1,"");
    }
}

FUNC::SpawnTimer(playerid)
{
    if(SQL_IsCharacterLogged(playerid))
    {
        ClearPlayerChat(playerid, 20);
        SendServerMessage(playerid, "Selamat datang {ffff00}%s{ffffff}.", ReturnName(playerid, 1));
        AccountData[playerid][uLoginDate] = gettime();
        TogglePlayerControllable(playerid, 1);

        CallLocalFunction("OnPlayerLogin", "d", playerid);
    }
    return 1;
}

timer ClearPlayerAnimations[3000](playerid)
{
    ClearAnimations(playerid);
    return 1;
}
timer GetUpAnimations[500](playerid)
{
    ApplyAnimation(playerid, "PED", "GETUP", 4.1, 0, 0, 0, 0, 0, 1);
    ApplyAnimation(playerid, "PED", "GETUP", 4.1, 0, 0, 0, 0, 0, 1);
    defer ClearPlayerAnimations(playerid);
    return 1;
}