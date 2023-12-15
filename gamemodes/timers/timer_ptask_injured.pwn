ptask Player_InjuredTimer[1000](playerid)
{
    if((!PlayerData[playerid][pLogged]) || !PlayerData[playerid][pCreated] || PlayerData[playerid][pKicked])
        return 0;

    if(PlayerData[playerid][pInjured])
    {
        if(PlayerData[playerid][pDead] <= 20.0 && !PlayerDeath[playerid])
        {
            PlayerDeath[playerid] = 1;
            InjuredTag(playerid, false, true);
        }
        if(PlayerData[playerid][pGiveupTime])
        {
            PlayerData[playerid][pGiveupTime] --;

            if(!PlayerData[playerid][pGiveupTime])
                SendServerMessage(playerid, "Sekarang kamu bisa gunakan perintah '"YELLOW"/giveup"WHITE"' untuk spawn ke rumah sakit!.");

        }
        return 1;
    }
    return 1;
}