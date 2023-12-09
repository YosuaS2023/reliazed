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